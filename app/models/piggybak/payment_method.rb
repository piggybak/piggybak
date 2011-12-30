module Piggybak 
  class PaymentMethod < ActiveRecord::Base
    has_many :payment_method_values
    alias :metadata :payment_method_values
    attr_accessible :klass, :label, :active

    def klass_enum 
      [::ActiveMerchant::Billing::AuthorizeNetGateway,
        ::ActiveMerchant::Billing::TrustCommerceGateway,
        ::ActiveMerchant::Billing::BraintreeGateway]
    end

    def key_values
      self.metadata.inject({}) { |h, k| h[k.key.to_sym] = k.value; h }
    end

    def admin_label
      "#{self.label}"
    end
  end
end
