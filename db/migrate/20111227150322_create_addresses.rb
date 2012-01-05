class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :firstname, :null => false
      t.string :lastname, :null => false
      t.string :address1, :null => false
      t.string :address2
      t.string :city, :null => false
      t.string :state_id, :null => false # because both text states and ids are allowed
      t.references :country, :null => false
      t.string :zip, :null => false

      t.timestamps
    end
  end
end
