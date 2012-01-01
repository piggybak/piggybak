module Piggybak
  class Shipment < ActiveRecord::Base
    belongs_to :order
    belongs_to :shipping_method

    validates_presence_of :status
    validates_presence_of :total
    validates_presence_of :shipping_method_id

    def status_enum
      ["new", "processing", "shipped"]
    end

    def admin_label
      cost = "$%.2f" % self.total
      "Shipment ##{self.id}<br />" +
      "#{self.shipping_method.description}<br />" +
      "Status: #{self.status}<br />" +
      "#{cost}"
    end
  end
end
