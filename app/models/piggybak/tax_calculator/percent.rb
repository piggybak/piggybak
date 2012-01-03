module Piggybak
  class TaxCalculator::Percent < TaxCalculator
    KEYS = ["state_abbr", "rate"]

    def self.available?(method, object)
      abbr = method.metadata.detect { |t| t.key == "state_abbr" }.value

      if object.is_a?(Cart)
        state = State.find(object.extra_data["state_id"])
        return state.abbr == abbr
      else
        if object.billing_address && object.billing_address.state 
          return object.billing_address.state.abbr == abbr
        end
      end
      return false
    end

    def self.rate(method, object)
      taxable_total = 0

      if object.is_a?(Cart)
        taxable_total = object.total
      else
        object.line_items.each do |line_item|
          taxable_total = line_item.total
        end
      end

      (method.metadata.detect { |m| m.key == "rate" }.value.to_f * taxable_total).to_c
    end
  end
end
