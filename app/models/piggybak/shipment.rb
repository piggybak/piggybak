module Piggybak
  class Shipment < ActiveRecord::Base
    belongs_to :order
    belongs_to :shipping_method
    belongs_to :line_item

    validates :status, presence: true
    validates :shipping_method_id, presence: true
    
    def status_enum
      ["new", "processing", "shipped"]
    end
  end
end
