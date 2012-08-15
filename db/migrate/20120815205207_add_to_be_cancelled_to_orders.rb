class AddToBeCancelledToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :to_be_cancelled, :boolean, :nil => false, :default => false
  end
end
