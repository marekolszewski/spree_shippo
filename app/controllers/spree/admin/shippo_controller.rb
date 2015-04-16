class Spree::Admin::ShippoController < Spree::Admin::BaseController
    include SpreeShippoLabels

    def show
        @shippo_connect_endpoint = SpreeShippoLabels.get_auth_url
        @store_url = SpreeShippoLabels::Config.instance.store_url
        @store_name = SpreeShippoLabels::Config.instance.store_name
        @partner_key = SpreeShippoLabels::Config.instance.partner_key
        @api_token = SpreeShippoLabels.get_api_token
        @register_automatically = SpreeShippoLabels::Config.instance.automatic_register_shippo_user
        @user_usps_set = SpreeShippoLabels::Config.instance.store_usps_enabled
    end

    def view_order
        redirect_to ( SpreeShippoLabels.get_orders_url(spree_current_user.email, params[:id]) )
    end

    def view_orders
        redirect_to ( SpreeShippoLabels.get_orders_url(spree_current_user.email) )
    end

end