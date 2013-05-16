class AddConfirmationSentToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :confirmation_sent, :boolean, :default => false
  end
end
