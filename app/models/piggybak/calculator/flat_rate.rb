module Piggybak
  class Calculator::FlatRate < Calculator
    KEYS = ["rate"]

    def self.description
      "Flat Rate"
    end

    def self.available?(method, cart)
      method.metadata.collect { |t| t.key }.sort == KEYS
    end

    def self.rate(method, cart)
      method.shipping_method_values.detect { |m| m.key == "rate" }.value
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
