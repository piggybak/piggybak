Piggybak::Engine.routes.draw do
  scope :module => "piggybak" do
    match "/show" => "orders#show", :as => :orders
    match "/cart" => "cart#show", :as => :cart
    match "/cart/add" => "cart#add", :via => :post, :as => :cart_add
    match "/cart/update" => "cart#update", :via => :post, :as => :cart_update
    match "/cart/remove/:item" => "cart#remove", :via => :delete
    match "/submit" => "orders#submit", :via => :post, :as => :order_submit
    match "/receipt" => "orders#receipt", :as => :receipt
    match "/orders" => "orders#list", :as => :orders_list
  end
end
