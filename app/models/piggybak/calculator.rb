module Piggybak
  class Calculator
    def self.available?(*args)
      false
    end

    def self.lookup(*args)
      { :available => false,
        :rate => 0.00 }
    end
  end
end
