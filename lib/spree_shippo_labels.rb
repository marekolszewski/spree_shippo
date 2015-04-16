require 'spree_core'
require 'spree_shippo_labels/engine'
require 'openssl'
require 'base64'
require 'digest'

module SpreeShippoLabels
  SPREE_SHIPPO_USER_EMAIL = "+spree@goshippo.com"
  BASE_URL                = "https://goshippo.com"
  SPREE_ENDPOINT          = "spreecommerce"
  AUTH_ENDPOINT           = "auth"
  ORDER_ENDPOINT          = "orders"

  def self.get_shippo_user
    api_user = Spree::User.find_or_initialize_by(email: Config.instance.api_user_email) do |user|
      user.password_confirmation = user.password = SecureRandom.hex(8)
      user.login                 = Config.instance.api_user_login
    end
    if api_user.new_record? && api_user.save!
      api_user.spree_roles << Spree::Role.find_or_create_by(name: 'admin')
      api_user.generate_spree_api_key!
    end
    api_user
  end

  def self.get_orders_url(email, order_id='', params={})
    uri       = URI([BASE_URL, SPREE_ENDPOINT, ORDER_ENDPOINT, order_id.blank? ? nil : order_id].compact.join('/'))
    params    = {
      store_name: Config.instance.store_name,
      store_url:  Config.instance.store_url,
      email:      email
    }.merge(params)
    uri.query = params.to_query
    uri.to_s
  end

  def self.get_auth_url
    [BASE_URL, SPREE_ENDPOINT, AUTH_ENDPOINT].join('/')
  end

  def self.get_api_token
    return unless Config.instance.partner_key.present? && Config.instance.partner_secret.present?

    secret_key = Base64.decode64(Config.instance.partner_secret)
    if secret_key.length == 32
      api_token = get_shippo_user.spree_api_key
      message   = encrypt(secret_key, api_token)
      return Base64.encode64(message)
    end
    return nil
  end

  def self.encrypt(secret, message)
    # add SHA to verify integrity when decrypting
    sha = Digest::SHA256.hexdigest message
    message << sha
    # create AES-256 Cipher
    cipher = OpenSSL::Cipher::AES.new(256, :CBC)
    cipher.encrypt
    cipher.key = secret
    # create new, random iv
    iv         = OpenSSL::Cipher::AES.new(256, :CBC).random_iv
    cipher.iv  = iv
    # return iv and encrypted message with padding
    return iv + cipher.update(message) + cipher.final
  end

  class Config
    include Singleton
    class << self
      def setup_instance(partner_config, store_config={})
        api_email    = build_api_user_email
        store_config = {
          store_name:           Spree::Config.site_name,
          api_user_email:       api_email,
          api_user_login:       api_email,
          store_url:            Spree::Config.site_url,
          automatic_register_shippo_user: false,
          store_usps_enabled: false,
          automatic_update_shipping: false
        }.merge(store_config)
        @@_instance  = new(partner_config, store_config)
      end

      def build_api_user_email
        return Spree::Config.site_name.gsub(/[^0-9A-Za-z]/, '').downcase + SPREE_SHIPPO_USER_EMAIL
      end

      def instance
        raise "please call setup_instance to initialize the instance before using it" unless @@_instance.present?
        @@_instance
      end

      def reset_instance
        @@_instance = nil
      end
    end

    attr_accessor :partner_key, :partner_secret,
                  :store_name, :api_user_email, :api_user_login, :store_url, :store_merchant_email,
                  :automatic_register_shippo_user, :store_usps_enabled, :automatic_update_shipping

    def initialize(partner_config, store_config={})
      @partner_key    = partner_config[:partner_key]
      @partner_secret = partner_config[:partner_secret]

      store_config.keys.each do |key|
        self.instance_variable_set("@#{key}".to_sym, store_config[key])
      end
    end
  end
end