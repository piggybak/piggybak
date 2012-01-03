Piggybak::Engine.routes.draw do
  scope :module => "piggybak" do
    match "/show" => "orders#show", :as => :orders
    match "/cart" => "cart#show", :as => :cart
    match "/cart/add" => "cart#add", :via => :post, :as => :cart_add
    match "/cart/update" => "cart#update", :via => :post, :as => :cart_update
    match "/cart/remove/:item" => "cart#remove", :via => :delete, :as => :remove_item
    match "/submit" => "orders#submit", :via => :post, :as => :order_submit
    match "/receipt" => "orders#receipt", :as => :receipt
    match "/orders" => "orders#list", :as => :orders_list
    match "/admin/orders/:id/email" => "orders#email", :as => :orders_email
    match "/orders/shipping" => "orders#shipping", :as => :orders_shipping
    match "/orders/tax" => "orders#tax", :as => :orders_tax
  end
end
