require 'spec_helper'
describe Spree::Admin::ShippoController do
  stub_authorization!

  before do
    SpreeShippoLabels::Config.setup({partner_key: 'shippo', partner_secret: '6fEhcH9FaAm95qNxpCDDiC5lagDJ+qrP40uDipFLVBA='})
    SpreeShippoLabels::Config.instance.add_store_config
    allow(controller).to receive(:spree_current_user).and_return(double(:user, email: 'test@test.com'))
  end

  describe "#show" do
    it "responds with a 200 status" do
      get :show, use_route: :shippo_settings
      expect(response.status).to be(200)
    end
    it "creates api user that shippo will use to connect back to the store to fetch the orders" do
      api_user_email = SpreeShippoLabels::Config.instance.api_user_email
      expect(Spree::User.find_by_email(api_user_email)).to be_nil
      get :show, use_route: :shippo_settings
      expect(Spree::User.find_by_email(api_user_email)).not_to be_nil
    end
  end

  describe "#view_order" do
    subject {get :view_order, use_route: :shippo_settings, id: 123}
    it "redirects to order url" do
      expect(subject).to redirect_to('https://goshippo.com/spreecommerce/orders/123')
    end
  end

  describe "#view_orders" do
    subject {get :view_orders, use_route: :shippo_settings, id: 123}
    it "redirects to orders url" do
      expect(subject).to redirect_to('https://goshippo.com/spreecommerce/orders')
    end
  end
end