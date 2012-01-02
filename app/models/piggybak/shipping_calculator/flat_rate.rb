module Piggybak
  class ShippingCalculator::FlatRate < ShippingCalculator
    KEYS = ["rate"]

    def self.available?(method, order)
      method.metadata.collect { |t| t.key }.sort == KEYS
    end

    def self.rate(method, order)
      method.metadata.detect { |m| m.key == "rate" }.value
    end

    def self.lookup(method, order)
      if self.available?(method, order)
        { :available => self.available?(method, order),
          :rate => self.rate(method, order) }
      else 
        { :available => self.available?(method, order) }
      end
    end
  end
end
