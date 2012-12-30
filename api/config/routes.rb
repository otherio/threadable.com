MultifyApi::Application.routes.draw do


  scope 'gitapi' do

    # for devise/ajax login
    devise_for :users, :controllers => {:sessions => 'sessions'}

    # resources :projects do
    #   resources :tasks do
    #     resources :doers
    #     resources :followers
    #   end
    #   resources :members
    # end`



    resources :projects, :tasks

    resources :users do
      collection do
        post :authenticate
      end
    end

    # devise wants this, but probably not forever.
    root :to => "home#index"

    devise_scope :user do
      match "users/register" => "registrations#create", :via => :post
    end

    #override the devise default
    # this doesn't quite work.
    #match "users" => "users#create", :via => :post
  end

  require Rails.root.join('../www_static/multify_front')
  match '/' => MultifyFront, :anchor => false

end
