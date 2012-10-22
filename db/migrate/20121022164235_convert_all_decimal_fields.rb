class ConvertAllDecimalFields < ActiveRecord::Migration
  def up
    change_column :line_items, :price, :decimal, :precision => 10, :scale => 2
    change_column :line_items, :unit_price, :decimal, :precision => 10, :scale => 2, :null => false, :defualt => 0.0
    change_column :orders, :total, :decimal, :precision => 10, :scale => 2, :null => false
    change_column :orders, :total_due, :decimal, :precision => 10, :scale => 2, :null => false
  end

  def down
    change_column :line_items, :price, :decimal
    change_column :line_items, :unit_price, :decimal
    change_column :orders, :total, :decimal
    change_column :orders, :total_due, :decimal
  end
end
