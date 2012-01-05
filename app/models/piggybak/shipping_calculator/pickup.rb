module Piggybak
  class ShippingCalculator::Pickup < ShippingCalculator
    KEYS = ["state_abbr", "rate"]

    def self.available?(method, object)
      abbr = method.metadata.detect { |t| t.key == "state_abbr" }.value

      if object.is_a?(Cart)
        state = State.find(object.extra_data["state_id"])
        return true if state && state.abbr == abbr
      else
        if object.billing_address && object.billing_address.state 
          return object.billing_address.state.abbr == abbr
        end
      end
      return false
    end

    def self.rate(method, object)
      method.metadata.detect { |m| m.key == "rate" }.value.to_f.to_c
    end
  end
end
