class FixSellablePriceScale < ActiveRecord::Migration
  def up
    change_column :sellables, :price, :decimal, :precision => 10, :scale => 2, :null => false
  end

  def down
    change_column :sellables, :price, :decimal
  end
end
