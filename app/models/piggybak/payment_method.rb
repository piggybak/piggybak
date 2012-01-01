module Piggybak 
  class PaymentMethod < ActiveRecord::Base
    has_many :payment_method_values, :dependent => :destroy
    alias :metadata :payment_method_values

    accepts_nested_attributes_for :payment_method_values, :allow_destroy => true

    validates_presence_of :klass
    validates_presence_of :description

    def klass_enum 
      [::Piggybak::PaymentCalculator::AuthorizeNet,
       ::Piggybak::PaymentCalculator::Fake]
    end

    validates_each :payment_method_values do |record, attr, value|
      if record.klass
        payment_method = record.klass.constantize
        metadata_keys = value.collect { |v| v.key }.sort
        if payment_method::KEYS.sort != metadata_keys
          record.errors.add attr, "You must define key values for #{payment_method::KEYS.join(', ')} for this payment method."
        end
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
