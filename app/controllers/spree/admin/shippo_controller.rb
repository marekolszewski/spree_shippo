class Spree::Admin::ShippoController < Spree::Admin::BaseController
  include SpreeShippoLabels

  def show
    cfg = SpreeShippoLabels::Config.instance
    @store_url               = cfg.store_url
    @store_name              = cfg.store_name
    @partner_key             = cfg.partner_key
    @register_automatically  = cfg.automatic_register_shippo_user
    @user_usps_set           = cfg.store_usps_enabled

    @shippo_connect_endpoint = SpreeShippoLabels.get_auth_url
    @api_token               = SpreeShippoLabels.get_api_token
  end

  def view_order
    redirect_to (SpreeShippoLabels.get_orders_url(spree_current_user.email, params[:id]))
  end

  def view_orders
    redirect_to (SpreeShippoLabels.get_orders_url(spree_current_user.email))
  end

end