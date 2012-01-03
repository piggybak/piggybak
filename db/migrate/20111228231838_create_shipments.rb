class CreateShipments < ActiveRecord::Migration
  def change
    create_table :shipments do |t|
      t.references :order, :null => false
      t.references :shipping_method, :null => false
      t.string :status, :null => false, :default => "new"
      t.decimal :total, :null => false, :default => 0.0

      t.timestamps
    end
  end
end
