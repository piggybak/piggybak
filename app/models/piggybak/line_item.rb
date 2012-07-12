module Piggybak
  class LineItem < ActiveRecord::Base
    belongs_to :order
    belongs_to :variant
  
    validates_presence_of :variant_id
    validates_presence_of :total
    validates_presence_of :price
    validates_presence_of :description
    validates_presence_of :quantity
    validates_numericality_of :quantity, :only_integer => true, :greater_than_or_equal_to => 0

    after_initialize :initialize_quantity
    after_create :decrease_inventory
    after_destroy :increase_inventory
    after_update :update_inventory
        
    def admin_label
      "#{self.quantity} x #{self.variant.description}"
    end

    def initialize_quantity
      self.quantity = 0
    end

    def decrease_inventory
      if !self.variant.unlimited_inventory
        self.variant.update_inventory(-1 * self.quantity)
      end
    end

    def increase_inventory
      self.variant.update_inventory(self.quantity)
    end

    def update_inventory
      if self.variant_id != self.variant_id_was
        old_variant = Variant.find(self.variant_id_was)
        old_variant.update_inventory(self.quantity_was)
        self.variant.update_inventory(-1*self.quantity)
      else
        quantity_diff = self.quantity_was - self.quantity
        self.variant.update_inventory(quantity_diff)
      end
    end
  end
end
