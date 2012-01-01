class CreatePaymentMethodValues < ActiveRecord::Migration
  def change
    create_table :payment_method_values do |t|
      t.references :payment_method
      t.string :key
      t.string :value
    end
  end
end
