class OrderDebugging < ActiveRecord::Migration
  def up
    add_column :orders, :ip_address, :string, :nil => false
    add_column :orders, :user_agent, :string, :nil => false
  end

  def down
    remove_column :orders, :ip_address
    remove_column :orders, :user_agent
  end
end
