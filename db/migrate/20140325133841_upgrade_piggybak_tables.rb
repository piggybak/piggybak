class UpgradePiggybakTables < ActiveRecord::Migration
  def change
    rename_table :orders, :piggybak_orders
    rename_table :addresses, :piggybak_addresses
    rename_table :line_items, :piggybak_line_items
    rename_table :shipping_methods, :piggybak_shipping_methods
    rename_table :payment_methods, :piggybak_payment_methods
    rename_table :payments, :piggybak_payments
    rename_table :shipments, :piggybak_shipments
    rename_table :shipping_method_values, :piggybak_shipping_method_values
    rename_table :payment_method_values, :piggybak_payment_method_values
    rename_table :tax_methods, :piggybak_tax_methods
    rename_table :countries, :piggybak_countries
    rename_table :states, :piggybak_states
    rename_table :tax_method_values, :piggybak_tax_method_values
    rename_table :order_notes, :piggybak_order_notes
    rename_table :sellables, :piggybak_sellables
  end
end
