Www::Application.routes.draw do

  get "/", :to => "home#index", :as => 'root'


  resource :authentication, :only => [:create, :destroy]

  get "/join", :to => "users#new", :as => 'join'
  resources :users

  resources :projects, :path => '/' do
    resources :tasks do
      resources :doers
      resources :followers
      resources :comments
    end
  end


end
