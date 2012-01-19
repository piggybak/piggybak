DummyApp::Application.routes.draw do
  devise_for :users

  root :to => "images#index"
  match 'image/:id' => "images#show", :as => :image

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'
  mount Piggybak::Engine => "/checkout", :as => 'piggybak'
end
