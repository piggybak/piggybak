module Piggybak
  class ShippingCalculator::FlatRate < ShippingCalculator
    KEYS = ["rate"]

    def self.available?(*args)
      true
    end

    def self.rate(method, object)
      method.metadata.detect { |m| m.key == "rate" }.value.to_f.to_c
    end
  end
end
