module Piggybak
  class ShippingCalculator::FlatRate
    KEYS = ["rate"]

    def self.description
      "Flat Rate"
    end

    def self.available?(*args)
      true
    end

    def self.rate(method, object)
      method.metadata.detect { |m| m.key == "rate" }.value.to_f
    end
  end
end
