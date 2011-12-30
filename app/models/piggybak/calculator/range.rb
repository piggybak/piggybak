module Piggybak
  class Calculator::Range < Calculator
    def self.description
      "Range"
    end

    def self.meta_keys
      ["cost", "lower", "upper"]
    end

    def self.available?(method, cart)
      return false if method.metadata.collect { |t| t.key }.sort != self.meta_keys.sort

      low_end = method.shipping_method_values.detect { |m| m.key == "lower" }.value
      high_end = method.shipping_method_values.detect { |m| m.key == "upper" }.value

      cart.total >= low_end.to_f && cart.total <= high_end.to_f
    end

    def self.rate(method, cart)
      method.shipping_method_values.detect { |m| m.key == "cost" }.value
    end

    def self.lookup(method, cart)
      if self.available?(method, cart)
        { :available => self.available?(method, cart),
          :rate => self.rate(method, cart) }
      else 
        { :available => self.available?(method, cart) }
      end
    end
  end
end
