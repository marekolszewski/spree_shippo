require 'spec_helper'

describe SpreeShippoLabels do
  class DummyClass
  end

  before(:all) do
    @dummy = DummyClass.new
    @dummy.extend SpreeShippoLabels
  end
  before(:each) do
    SpreeShippoLabels::Config.reset_instance
  end

  context "module methods" do
    before do
      SpreeShippoLabels::Config.setup({partner_key: 'shippo_test', partner_secret: '6fEhcH9FaAm95qNxpCDDiC5lagDJ+qrP40uDipFLVBA='})
      SpreeShippoLabels::Config.instance.add_store_config
    end
    describe "get_orders_url" do
      it "retrieves orders url" do
        expect(SpreeShippoLabels.get_orders_url('abc')).to eq('https://goshippo.com/spreecommerce/orders/abc')
      end
      it "tacks additional parameters to orders url if passed" do
        expect(SpreeShippoLabels.get_orders_url('abcd', { pdf_render_url: 'https://foo.com/orders/shipping_label'})).to eq('https://goshippo.com/spreecommerce/orders/abcd?pdf_render_url=https%3A%2F%2Ffoo.com%2Forders%2Fshipping_label')
      end
      it "retrieves the orders url when no id passed" do
        expect(SpreeShippoLabels.get_orders_url).to eq('https://goshippo.com/spreecommerce/orders')
      end
    end

    describe "get_auth_url" do
      it "retrieves authentication url" do
        expect(SpreeShippoLabels.get_auth_url).not_to be_empty
      end
    end

    describe "get_api_token_no_partner" do
      it "does not return the api token" do
        SpreeShippoLabels::Config.setup({partner_key: nil, partner_secret: nil})
        expect(SpreeShippoLabels.get_api_token).to be_nil
      end
    end

    describe "get_api_token_with_partner" do
      it "returns encrypted api token" do
        SpreeShippoLabels::Config.setup({partner_key: 'shippo', partner_secret: '6fEhcH9FaAm95qNxpCDDiC5lagDJ+qrP40uDipFLVBA='})
        SpreeShippoLabels::Config.instance.add_store_config
        expect(SpreeShippoLabels.get_api_token).not_to be_nil
      end
    end

    describe "get_api_token_with_partner_wrong_length" do
      it "does not return the api token" do
        SpreeShippoLabels::Config.setup({partner_key: 'shippo', partner_secret: '6fEhcH9FaAm95qNxpCDDiC5lagDJ+qrP40uDipFLV'})
        SpreeShippoLabels::Config.instance.add_store_config
        expect(SpreeShippoLabels.get_api_token).to be_nil
      end
    end
  end

  describe "Config" do
    describe "#instance" do
      it "raises an error when setup_instance hasn't been called before" do
        expect { SpreeShippoLabels::Config.instance }.to raise_error(RuntimeError, "please call setup to initialize the instance before using it")
      end
      it "does not raise an error if setup_instance has been called before" do
        SpreeShippoLabels::Config.setup({partner_key: 'shippo', partner_secret: '6fEhcH9FaAm95qNxpCDDiC5lagDJ+qrP40uDipFLVBA='})
        expect { SpreeShippoLabels::Config.instance }.not_to raise_error
      end
    end
    describe "setup_instance" do
      it "initializes the instance with default store values" do
        SpreeShippoLabels::Config.setup({partner_key: 'shippo', partner_secret: '6fEhcH9FaAm95qNxpCDDiC5lagDJ+qrP40uDipFLVBA='})
        SpreeShippoLabels::Config.instance.add_store_config()
        cfg = SpreeShippoLabels::Config.instance
        expect(cfg).to be
        expect(cfg.store_name).to eq('Spree Demo Site')
        expect(cfg.store_url).to eq('demo.spreecommerce.com')
        expect(cfg.auth_url).to eq('https://goshippo.com/spreecommerce/auth/')
        expect(cfg.order_base_url).to eq('https://goshippo.com/spreecommerce/orders')
        expect(cfg.api_user_email).to eq('spreedemosite+spree@goshippo.com')
        expect(cfg.api_user_login).to eq('spreedemosite+spree@goshippo.com')
        expect(cfg.automatic_register_shippo_user).to eq(true)
        expect(cfg.store_usps_enabled).to eq(true)
        expect(cfg.automatic_update_shipping).to eq(false)
      end
      it "overrides the store config when specified" do
        SpreeShippoLabels::Config.setup({partner_key: 'shippo',
                                                  partner_secret: '6fEhcH9FaAm95qNxpCDDiC5lagDJ+qrP40uDipFLVBA='})
        SpreeShippoLabels::Config.instance.add_store_config({
                                                   store_name: (sn = 'abc'),
                                                   store_url: (su = 'a.b.c.'),
                                                   auth_url: (au = 'http://a.b/c/d'),
                                                   order_base_url: (obu = 'http://a.b/c/d'),
                                                   api_user_email: (aue = 'a@b.com'),
                                                   api_user_login: (aul = 'b@c.com'),
                                                   automatic_register_shippo_user: false,
                                                   store_usps_enabled: true,
                                                   automatic_update_shipping: true
                                                 })
        cfg = SpreeShippoLabels::Config.instance
        expect(cfg).to be
        expect(cfg.store_name).to eq(sn)
        expect(cfg.store_url).to eq(su)
        expect(cfg.auth_url).to eq(au)
        expect(cfg.order_base_url).to eq(obu)
        expect(cfg.api_user_email).to eq(aue)
        expect(cfg.api_user_login).to eq(aul)
        expect(cfg.automatic_register_shippo_user).to eq(false)
        expect(cfg.store_usps_enabled).to eq(true)
        expect(cfg.automatic_update_shipping).to eq(true)
      end
    end
  end
end