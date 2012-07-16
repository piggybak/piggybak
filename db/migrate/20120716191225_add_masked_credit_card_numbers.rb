class AddMaskedCreditCardNumbers < ActiveRecord::Migration
  def up
    add_column :payments, :masked_number, :string, :nil => false
  end

  def down
    remove_column :payments, :masked_number
  end
end
