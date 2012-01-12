DummyApp::Application.routes.draw do
  mount Piggybak::Engine => '/demo/checkout', :as => 'piggybak'

  devise_for :users

  match "/demo/" => 'home#index', :as => :root
  match '/demo/image/:id' => 'images#show', :as => :image
  match '/demo/c/:id' => 'categories#show', :as => :category
  match '/demo/:slug' => 'pages#show'
end
