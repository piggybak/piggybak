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
      taxable_total = object.subtotal
      if object.is_a?(::Piggybak::Order)
        Piggybak.config.line_item_types.each do |k, v|
          if v.has_key?(:reduce_tax_subtotal) && v[:reduce_tax_subtotal]
            taxable_total += object.send("#{k}_charge")
          end
        end
      else
        taxable_total += object.extra_data[:reduce_tax_subtotal].to_f
      end
      (method.metadata.detect { |m| m.key == "rate" }.value.to_f * taxable_total).to_c
    end
  end
end
