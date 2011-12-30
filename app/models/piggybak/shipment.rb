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
      "Shipment: ##{self.id}"
    end
  end
end
