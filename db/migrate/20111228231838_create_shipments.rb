class CreateShipments < ActiveRecord::Migration
  def change
    create_table :shipments do |t|
      t.references :order, :null => false
      t.references :shipping_method, :null => false
      t.string :status, :null => false, :default => "new"
      t.total :float

      t.timestamps
    end
  end
end
