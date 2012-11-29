MultifyApi::Application.routes.draw do

  # for devise/ajax login
  devise_for :users, :controllers => {:sessions => 'sessions'}

  # resources :projects do
  #   resources :tasks do
  #     resources :doers
  #     resources :followers
  #   end
  #   resources :members
  # end`



  resources :projects

  resources :tasks

  resources :users do
    collection do
      post :authenticate
    end
  end

  # devise wants this, but probably not forever.
  root :to => "home#index"

end
