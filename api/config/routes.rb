MultifyApi::Application.routes.draw do


  scope 'api' do

    # for devise/ajax login
    devise_for :users, :controllers => {:sessions => 'sessions'}

    # resources :projects do
    #   resources :tasks do
    #     resources :doers
    #     resources :followers
    #   end
    #   resources :members
    # end`



    resources :projects do
      member do
        get :tasks
      end
    end
    resources :tasks

    resources :users do
      collection do
        post :authenticate
      end
    end

    devise_scope :user do
      match "users/register" => "registrations#create", :via => :post
    end

    #override the devise default
    # this doesn't quite work.
    #match "users" => "users#create", :via => :post
  end

  require Rails.root.join('../www/server')
  match '/' => Multify::Www::Server, :anchor => false

end
