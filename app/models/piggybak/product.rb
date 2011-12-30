class Piggybak::Product < ActiveRecord::Base
  belongs_to :item, :polymorphic => true, :inverse_of => :piggybak_product
  attr_accessible :sku, :description, :price, :quantity, :active, :unlimited_inventory, :item_id, :item_type

  validates_presence_of :sku
  validates_uniqueness_of :sku
  validates_presence_of :description
  validates_presence_of :price
  validates_presence_of :item_type
  validates_numericality_of :quantity, :only_integer => true, :greater_than_or_equal_to => 0
    
  def admin_label
    "Product: #{self.description}"
  end

  def decrease_quantity(purchased)
    self.update_attribute(:quantity, self.quantity - purchased)
  end
end
