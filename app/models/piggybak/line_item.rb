module Piggybak
  class LineItem < ActiveRecord::Base
    belongs_to :order
    belongs_to :product
  
    validates_presence_of :product_id
    validates_presence_of :total
    validates_presence_of :quantity
        
    def admin_label
      "Line Item: #{self.quantity}x#{self.product.description}"
    end
  end
end
