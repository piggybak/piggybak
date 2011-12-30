Piggybak::Engine.routes.draw do
  scope :module => "piggybak" do
    match "/show" => "orders#show", :as => :orders
    match "/cart" => "cart#show", :as => :cart
    match "/cart/add" => "cart#add", :via => :post, :as => :cart_add
    match "/cart/remove/:item" => "cart#remove", :via => :post
    match "/submit" => "orders#submit", :via => :post
    match "/receipt" => "orders#receipt", :as => :receipt
  end
end
