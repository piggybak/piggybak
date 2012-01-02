module Piggybak
  class TaxCalculator::FlatRate < TaxCalculator
    KEYS = ["state_abbr", "rate"]

    def self.available?(method, order)
      abbr = method.metadata.detect { |t| t.key == "state_abbr" }.value
      order.billing_address.state.abbr == abbr
    end

    def self.rate(method, order)
      taxable_total = 0
      order.line_items.each do |line_item|
        taxable_total = line_item.total
      end

      method.metadata.detect { |m| m.key == "rate" }.value.to_f * taxable_total
    end
  end
end
