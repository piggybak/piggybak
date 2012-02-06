Piggybak::Engine.routes.draw do
  scope :module => "piggybak" do
    # cart actions
    match "/cart" => "cart#show", :as => :cart
    match "/cart/add" => "cart#add", :via => :post, :as => :cart_add
    match "/cart/update" => "cart#update", :via => :post, :as => :cart_update
    match "/cart/remove/:item" => "cart#remove", :via => :delete, :as => :remove_item

    # order actions
    root :to => 'orders#submit', :as => :orders, :via => [:get, :post]
    match "/receipt" => "orders#receipt", :as => :receipt
    match "/orders/shipping" => "orders#shipping", :as => :orders_shipping
    match "/orders/tax" => "orders#tax", :as => :orders_tax
    match "/orders/geodata" => "orders#geodata", :as => :orders_geodata

    # list orders
    match "/orders" => "orders#list", :as => :orders_list

    # admin actions
    match "/admin/orders/:id/email" => "orders#email", :as => :email_order
    match "/admin/orders/:id/download" => "orders#download", :as => :download_order, :format => "txt"
    match "/admin/orders/:id/cancel" => "orders#cancel", :as => :cancel_order
    match "/admin/payments/:id/refund" => "payments#refund", :as => :refund_payment
  end
end
