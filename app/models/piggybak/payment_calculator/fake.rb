module Piggybak
  class PaymentCalculator::Fake
    KEYS = []
    KLASS = ::Piggybak::PaymentCalculator::Fake

    def self.new(*args)
      return self
    end

    def self.authorize(*args)
      self
    end

    def self.success?
      true
    end

    def self.authorization
    end

    def self.capture(*args)
    end

    def self.transaction_id(*args)
      "N/A"
    end
  end
end
