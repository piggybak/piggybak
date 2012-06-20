module Piggybak
  class TaxCalculator::Percent
    KEYS = ["state_id", "rate"]

    def self.available?(method, object)
      id = method.metadata.detect { |t| t.key == "state_id" }.value

      if object.is_a?(Cart)
        if object.extra_data[:state_id] != ""
          state = State.find(object.extra_data[:state_id])
          return state.id == id.to_i if state
        end
      else
        if object.billing_address && object.billing_address.state 
          return object.billing_address.state.id == id.to_i
        end
      end
      return false
    end

    def self.rate(method, object)
      taxable_total = 0

      if object.is_a?(Cart)
        taxable_total = object.total
      else
        taxable_total = order.subtotal
      end

      (method.metadata.detect { |m| m.key == "rate" }.value.to_f * taxable_total).to_c
    end
  end
end
