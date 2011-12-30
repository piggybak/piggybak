class CreateShippingMethodValues < ActiveRecord::Migration
  def change
    create_table :shipping_method_values do |t|
      t.references :shipping_method
      t.string :key
      t.string :value
    end
  end
end
