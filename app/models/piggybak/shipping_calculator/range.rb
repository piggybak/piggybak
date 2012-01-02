module Piggybak
  class ShipppingCalculator::Range < ShippingCalculator
    KEYS = ["cost", "upper", "lower"]

    def self.available?(method, order)
      return false if method.metadata.collect { |t| t.key }.sort != KEYS.sort

      low_end = method.metadata.detect { |m| m.key == "lower" }.value
      high_end = method.metadata.detect { |m| m.key == "upper" }.value

      order.total >= low_end.to_f && order.total <= high_end.to_f
    end

    def self.rate(method, order)
      method.metadata.detect { |m| m.key == "cost" }.value
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
