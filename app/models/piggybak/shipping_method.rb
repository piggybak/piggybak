module Piggybak
  class ShippingMethod < ActiveRecord::Base
    has_many :shipping_method_values
    alias :metadata :shipping_method_values
    validates_presence_of :klass

    def klass_enum 
      Piggybak::Calculator.subclasses
    end

    def self.available_methods(cart)
      active_methods = ShippingMethod.find_all_by_active(true)

      active_methods.select { |method| method.klass.constantize.available?(method, cart) }
    end

    def self.lookup_methods(cart)
      active_methods = ShippingMethod.find_all_by_active(true)

      active_methods.inject([]) do |arr, method|
        klass = method.klass.constantize
        b = klass.lookup(method, cart)
        arr << ["#{klass.description} #{b[:rate]}", method.id] if b[:available]
        arr
      end
    end
    def admin_label
      self.description
    end
  end
end
