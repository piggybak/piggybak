class AddPriceToLineItem < ActiveRecord::Migration
  def up
    add_column :line_items, :price, :decimal, :null => false, :default => 0.0
    
    change_table(:line_items) do |t|
      t.timestamps
    end

    Piggybak::LineItem.all.each do |line_item|
      line_item.update_attribute(:price, line_item.total/line_item.quantity)
    end
  end

  def down
    remove_column :line_items, :price
  end
end
