class AddActiveToCountries < ActiveRecord::Migration
  def up
    add_column :countries, :active_shipping, :boolean, :default => false
    add_column :countries, :active_billing, :boolean, :default => false
  end

  def down
    remove_column :countries, :active_shipping
    remove_column :countries, :active_billing
  end
end
