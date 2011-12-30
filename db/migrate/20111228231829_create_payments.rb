class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.references :order
      t.references :payment_method
      t.string :status
      t.float :total

      t.timestamps
    end
  end
end
