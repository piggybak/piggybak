DummyApp::Application.routes.draw do
  mount Piggybak::Engine => '/demo/checkout', :as => 'piggybak'

  match "/" => 'home#index', :as => :root
  match '/image/:id' => 'images#show', :as => :image
  match '/c/:id' => 'categories#show', :as => :category
  match '/:slug' => 'pages#show'
end
