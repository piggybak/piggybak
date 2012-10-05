module Piggybak
  class ShippingCalculator::Free
    KEYS = []

    def self.description
      "Free Shipping"
    end

    def self.available?(method, object)
      true
    end

    def self.rate(method, object)
      0.00
    end
  end
end
