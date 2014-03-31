module Piggybak
  module Config
    class << self
      attr_accessor :payment_calculators
      attr_accessor :shipping_calculators
      attr_accessor :tax_calculators
      attr_accessor :default_country
      attr_accessor :activemerchant_mode
      attr_accessor :email_sender
      attr_accessor :order_cc
      attr_accessor :logging
      attr_accessor :logging_file
      attr_accessor :whois_url
      attr_accessor :line_item_types
      attr_accessor :secure_checkout
      attr_accessor :secure_prefix
      attr_accessor :extra_secure_paths
      attr_accessor :manage_classes
      attr_accessor :extra_abilities
      attr_accessor :additional_line_item_attributes

      def reset
        @manage_classes = ["::Piggybak::Sellable",
                           "::Piggybak::ShippingMethod",
                           "::Piggybak::PaymentMethod",
                           "::Piggybak::TaxMethod",
                           "::Piggybak::State",
                           "::Piggybak::Country",
                           "::Piggybak::Order"]
        @extra_abilities = []

        @email_sender = "support@piggybak.org"
        @order_cc = nil

        @payment_calculators = ["::Piggybak::PaymentCalculator::Fake",
                                "::Piggybak::PaymentCalculator::AuthorizeNet"]
        @shipping_calculators = ["::Piggybak::ShippingCalculator::FlatRate",
                                 "::Piggybak::ShippingCalculator::Free",
                                 "::Piggybak::ShippingCalculator::Range"]
        @tax_calculators = ["::Piggybak::TaxCalculator::Percent"]

        @line_item_types = { :sellable => { :visible => true,
                                            :fields => ["sellable_id", "quantity"],
                                            :allow_destroy => true,
                                            :sort => 1 },
                             :payment => { :visible => true,
                                           :nested_attrs => true,
                                           :fields => ["payment"],
                                           :allow_destroy => false,
                                           :class_name => "::Piggybak::Payment",
                                           :sort => 5 },
                             :shipment => { :visible => true, 
                                            :nested_attrs => true, 
                                            :fields => ["shipment"], 
                                            :allow_destroy => true,
                                            :class_name => "::Piggybak::Shipment", 
                                            :sort => 2 },
                             :adjustment => { :visible => true, 
                                              :fields => ["description", "price"],
                                              :allow_destroy => true,
                                              :sort => 4 },
                             :tax => { :visible => false, 
                                       :allow_destroy => false,
                                       :sort => 3 }
                           }

        @default_country = "US"

        @activemerchant_mode = :test

        @logging = false
        @logging_file = "/log/orders.log"

        @whois_url = nil

        @secure_checkout = false
        @secure_prefix = ''
        @extra_secure_paths = []
        @additional_line_item_attributes = {}
      end
    end

    self.reset
  end
end
