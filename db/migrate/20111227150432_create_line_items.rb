class CreateLineItems < ActiveRecord::Migration
  def change
    create_table :line_items do |t|
      t.references :order, :null => false
      t.integer :quantity, :null => false
      t.references :variant, :null => false
      t.decimal :total
      t.timestamps
    end
  end
end
