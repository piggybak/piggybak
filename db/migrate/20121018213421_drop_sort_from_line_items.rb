class DropSortFromLineItems < ActiveRecord::Migration
  def up
    remove_column :line_items, :sort
  end

  def down
    add_column :line_items, :sort, :integer, :null => false, :default => 0
  end
end
