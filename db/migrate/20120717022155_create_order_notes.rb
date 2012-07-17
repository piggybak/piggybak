class CreateOrderNotes < ActiveRecord::Migration
  def change
    create_table :order_notes do |t|
      t.references :order, :null => false
      t.references :user, :null => false
      t.text :note
      t.timestamps
    end  
  end
end
