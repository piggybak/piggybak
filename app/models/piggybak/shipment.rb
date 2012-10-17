module Piggybak
  class Shipment < ActiveRecord::Base
    belongs_to :order
    belongs_to :shipping_method
    belongs_to :line_item

    validates_presence_of :status
    validates_presence_of :shipping_method_id
    
    attr_accessible :shipping_method_id, :status
    
    def status_enum
      ["new", "processing", "shipped"]
    end
  end
end
