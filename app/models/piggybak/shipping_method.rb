module Piggybak
  class ShippingMethod < ActiveRecord::Base
    
    # klass_enum requires the ShippingCalculator subclasses to be loaded
    shipping_calcs_path = File.expand_path("../shipping_calculator", __FILE__)
    Dir.glob(shipping_calcs_path + "**/*.rb").each do |subclass|
      ActiveSupport::Dependencies.require_or_load subclass
    end 
    
    has_many :shipping_method_values, :dependent => :destroy
    alias :metadata :shipping_method_values

    validates_presence_of :description
    validates_presence_of :klass

    accepts_nested_attributes_for :shipping_method_values, :allow_destroy => true

    validates_each :shipping_method_values do |record, attr, value|
      if record.klass
        calculator = record.klass.constantize
        metadata_keys = value.collect { |v| v.key }.sort
        if calculator::KEYS.sort != metadata_keys
          record.errors.add attr, "You must define key values for #{calculator::KEYS.join(', ')} for this shipping method."
        end
      end
    end

    def klass_enum
      Piggybak::ShippingCalculator.subclasses
    end

    def self.available_methods(cart)
      active_methods = ShippingMethod.find_all_by_active(true)

      active_methods.select { |method| method.klass.constantize.available?(method, cart) }
    end

    def self.lookup_methods(cart)
      active_methods = ShippingMethod.find_all_by_active(true)

      active_methods.inject([]) do |arr, method|
        klass = method.klass.constantize
        if klass.available?(method, cart)
          rate = klass.rate(method, cart)
          arr << {
            :label => "#{method.description} $#{"%.2f" % rate}",
			:id => method.id,
            :rate => rate }
		end
        arr
      end
    end
    def admin_label
      self.description
    end
  end
end
