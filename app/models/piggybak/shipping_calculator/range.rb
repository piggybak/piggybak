module Piggybak
  class ShippingCalculator::Range
    KEYS = ["cost", "upper", "lower"]

    def self.description
      "Cost per Range"
    end

    def self.available?(method, object)
      low_end = method.metadata.detect { |m| m.key == "lower" }.value
      high_end = method.metadata.detect { |m| m.key == "upper" }.value

      object.total >= low_end.to_f && object.total <= high_end.to_f
    end

    def self.rate(method, object)
      method.metadata.detect { |m| m.key == "cost" }.value.to_f
    end
  end
end
