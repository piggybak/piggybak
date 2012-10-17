module Piggybak
  module FormattedChanges
    extend ActiveSupport::Concern

    def new_destroy_changes(type)
      text = "#{self.class.to_s.gsub(/Piggybak::/, '')} ##{self.id} #{type}:<br />"
      self.attributes.each do |k, v|
        if !["updated_at", "created_at", "id", "order_id", "billing_address_id", "shipping_address_id", "sellable_id", "line_item_type", "unit_price", "sort"].include?(k)
          if v.is_a?(BigDecimal)
            text += "#{k}: $#{format("%.2f", v)}<br />"
          else
            text += "#{k}: #{v}<br />"
          end
        end
      end

      return text
    end

    def formatted_changes
      text = "#{self.class.to_s.gsub(/Piggybak::/, '')} ##{self.id} changes:<br />"
      self.changes.each do |k, v|
        if !["updated_at", "id", "billing_address_id", "shipping_address_id", "created_at", "sellable_id", "line_item_type", "unit_price", "sort"].include?(k)
          if v[0].is_a?(BigDecimal)
            text += "#{k}: $#{format("%.2f", v[0])} to $#{format("%.2f", v[1])}<br />"
          else
            text += "#{k}: #{v[0]} to #{v[1]}<br />"
          end
        end
      end

      return text
    end
  end
end

::ActiveRecord::Base.send :include, Piggybak::FormattedChanges
