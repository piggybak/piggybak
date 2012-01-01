class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.references :order
      t.references :payment_method
      t.string :status, :null => false, :default => 'paid'
      t.float :total, :null => false, :default => 0.0

      t.string :number
      t.integer :month
      t.integer :year
      t.string :verification_value

      t.timestamps
    end
  end
end
