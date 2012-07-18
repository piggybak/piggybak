class ModifyCredits < ActiveRecord::Migration
  def change
    rename_table :credits, :adjustments
    add_column :adjustments, :note, :text
  end
end
