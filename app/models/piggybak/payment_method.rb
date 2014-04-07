module Piggybak 
  class PaymentMethod < ActiveRecord::Base
    has_many :payment_method_values, :dependent => :destroy
    alias :metadata :payment_method_values

    accepts_nested_attributes_for :payment_method_values, :allow_destroy => true

    validates :klass, presence: true
    validates :description, presence: true
    
    def klass_enum 
      Piggybak.config.payment_calculators
    end

    validates_each :payment_method_values do |record, attr, value|
      if record.klass.present?
        payment_method = record.klass.constantize
        metadata_keys = value.collect { |v| v.key }.sort
        if payment_method::KEYS.sort != metadata_keys
          if payment_method::KEYS.empty?
            record.errors.add attr, "You don't need any metadata for this method."
          else
            record.errors.add attr, "You must define key values for #{payment_method::KEYS.join(', ')} for this payment method."
          end
        end
      end
    end
    validates_each :active do |record, attr, value|
      if value && PaymentMethod.where(active: true).select { |p| p != record }.size > 0
        record.errors.add attr, "You may only have one active payment method."
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
