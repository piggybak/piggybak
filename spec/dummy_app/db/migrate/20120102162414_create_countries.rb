require "countries"

class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries do |t|
      t.string :name
      t.string :abbr

      t.boolean :active_shipping, :default => false
      t.boolean :active_billing, :default => false
    end
  end
end
