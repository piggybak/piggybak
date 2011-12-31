module Piggybak 
  class PaymentMethod < ActiveRecord::Base
    has_many :payment_method_values, :dependent => :destroy
    alias :metadata :payment_method_values

    accepts_nested_attributes_for :payment_method_values, :allow_destroy => true

    validates_presence_of :klass
    validates_presence_of :description

    def klass_enum 
      [::ActiveMerchant::Billing::AuthorizeNetGateway,
        ::ActiveMerchant::Billing::TrustCommerceGateway,
        ::ActiveMerchant::Billing::BraintreeGateway]
    end

    validates_each :payment_method_values do |record, attr, value|
      metadata_keys = value.collect { |v| v.key }.sort
      if ["login", "password"] != metadata_keys
        record.errors.add attr, "You must define metadata for login, password for this payment method."
      end
    end

    def key_values
      self.metadata.inject({}) { |h, k| h[k.key.to_sym] = k.value; h }
    end

    def admin_label
      "#{self.description}"
    end
  end
end
