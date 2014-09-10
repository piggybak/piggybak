class AddPriceToLineItem < ActiveRecord::Migration
  def up
    Piggybak::LineItem.class_eval do
      self.table_name = 'line_items'
    end

    add_column :line_items, :price, :decimal, :null => false, :default => 0.0
    Piggybak::LineItem.all.each do |line_item|
      line_item.update_attribute(:price, line_item.total/line_item.quantity)
    end
  end

  def down
    remove_column :line_items, :price
  end
end
