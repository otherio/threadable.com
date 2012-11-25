Www::Application.routes.draw do

  get "/", :to => "home#index", :as => 'root'


  resource :authentication, :only => [:create, :destroy]

  get "/join", :to => "users#new", :as => 'join'
  resources :users

  resources :projects, :path => '/' do
    resources :tasks do
      member do
        get 'become_a_doer'
        get 'become_a_follower'
        get 'unsubscribe'
      end
    end
  end


end
