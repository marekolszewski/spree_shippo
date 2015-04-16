##########################################################
# partner_config - SHIPPO PARTNER ACCESS SETTINGS
# The partner key is the human-readable Shippo partner name.
# The partner secret is a 32 character token, issued by Shippo
#
# store config
#  automatic_register_shippo_user: automatically register a new
#             user and email a temp password to the merchant email
#  store_usps_enabled: if the store has usps enabled by default,
#             the carrier selection is skipped in shippo onboarding flow
#  automatic_update_shipping: update the spree store orders with
#             tracking and shipment information when a shipping
#             label is purchased
##########################################################
SpreeShippoLabels::Config.setup({
                                  partner_key:    nil,
                                  partner_secret: nil
                                })
SpreeShippoLabels::Config.instance.add_store_config({
                                                      automatic_register_shippo_user: false,
                                                      store_usps_enabled:             false,
                                                      automatic_update_shipping:      false
                                                    })