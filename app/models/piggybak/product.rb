class Piggybak::Product < ActiveRecord::Base
  belongs_to :item, :polymorphic => true, :inverse_of => :piggybak_product
  attr_accessible :sku, :description, :price, :quantity, :active, :unlimited_inventory, :item_id, :item_type

  validates_presence_of :sku
  validates_uniqueness_of :sku
  validates_presence_of :description
  validates_presence_of :price
  validates_presence_of :item_type
    
  def admin_label
    "Product: #{self.description}"
  end
end
