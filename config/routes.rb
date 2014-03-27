Piggybak::Engine.routes.draw do
  # cart actions
  get '/cart' => 'cart#show'
  post '/cart/add' => 'cart#add', as: :cart_add
  post '/cart/update' => 'cart#update', as: :cart_update
  delete '/cart/remove/:item' => 'cart#remove', as: :remove_item

  # order actions
  root 'orders#submit', as: :orders, via: [:get, :post]
  get '/receipt' => 'orders#receipt', as: :receipt
  get '/orders/shipping' => 'orders#shipping', as: :orders_shipping
  get '/orders/tax' => 'orders#tax', as: :orders_tax
  get '/orders/geodata' => 'orders#geodata', as: :orders_geodata

  # list orders
  get '/orders' => 'orders#list', as: :orders_list

  # admin actions
  get '/admin/orders/:id/email' => 'orders#email', as: :email_order
  get '/admin/orders/:id/download' => 'orders#download', as: :download_order, :format => 'txt'
  get '/admin/orders/:id/cancel' => 'orders#cancel', as: :cancel_order
end
