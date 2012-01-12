class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.references :order
      t.references :payment_method
      t.string :status, :null => false, :default => 'paid'
      t.decimal :total, :null => false, :default => 0.0

      t.integer :month
      t.integer :year
      t.string :transaction_id

      t.timestamps
    end
  end
end
