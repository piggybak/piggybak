module Piggybak
  class ShippingMethod < ActiveRecord::Base
    has_many :shipping_method_values, :dependent => :destroy
    alias :metadata :shipping_method_values

    validates :description, presence: true
    validates :klass, presence: true

    accepts_nested_attributes_for :shipping_method_values, :allow_destroy => true

    validates_each :shipping_method_values do |record, attr, value|
      if record.klass.present?
        calculator = record.klass.constantize
        metadata_keys = value.collect { |v| v.key }.sort
        if calculator::KEYS.sort != metadata_keys
          if calculator::KEYS.empty?
            record.errors.add attr, "You don't need any metadata for this method."
          else
            record.errors.add attr, "You must define key values for #{calculator::KEYS.join(', ')} for this shipping method."
          end
        end
      end
    end

    def klass_enum
      Piggybak.config.shipping_calculators.collect { |b| [ b.constantize.description, b ] }
    end

    def self.available_methods(cart)
      active_methods = ShippingMethod.where(active: true)

      active_methods.select { |method| method.klass.constantize.available?(method, cart) }
    end

    def self.lookup_methods(cart)
      active_methods = ShippingMethod.where(active: true)

      methods = active_methods.inject([]) do |arr, method|
        klass = method.klass.constantize
        if klass.available?(method, cart)
          rate = klass.rate(method, cart)
          arr << {
            :label => "#{method.description} $#{"%.2f" % rate}",
            :id => method.id,
            :rate => rate.to_f }
          end
        arr
      end

      methods.sort_by { |b| b[:rate] }
    end
    def admin_label
      self.description
    end
  end
end
