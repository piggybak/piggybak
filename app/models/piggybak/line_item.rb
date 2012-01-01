module Piggybak
  class LineItem < ActiveRecord::Base
    belongs_to :order
    belongs_to :product
  
    validates_presence_of :product_id
    validates_presence_of :total
    validates_presence_of :quantity
    validates_numericality_of :quantity, :only_integer => true, :greater_than_or_equal_to => 0

    after_create :decrease_inventory
        
    def admin_label
      "Line Item: #{self.quantity} x #{self.product.description}"
    end

    def decrease_inventory
      self.product.decrease_inventory(self.quantity)
    end
  end
end
