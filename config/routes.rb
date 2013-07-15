Covered::Application.routes.draw do

  unless Rails.env.production?
    get '/test/javascripts' => 'test/javascripts#show', as: 'javascript_tests'
  end

  namespace :admin do
    require 'resque/server'
    mount Resque::Server, :at => "/resque"
  end

  get '/development' => 'development#index'
  get '/demoauth' => 'demo_auth#index', as: 'demo_auth'

  # get "users/confirmation" => "confirmations#show", as: 'user_confirmation'
  devise_for :users, :controllers => {
    :registrations => 'registrations',
    :confirmations => 'confirmations',
    :omniauth_callbacks => "users/omniauth_callbacks",
    :registrations => "registrations"
  }

  devise_scope :user do
    get '/thanks-for-signing-up' => 'registrations#thanks', as: 'thanks_for_signing_up'
    put "/users/confirm" => "confirmations#confirm", as: 'user_confirm'
  end


  get   '/projects'      => 'projects#index'
  get   '/:id/edit'      => 'projects#edit',      :as => 'edit_project'
  get   '/:id'           => 'projects#show',      :as => 'project'
  put   '/:id'           => 'projects#update'
  patch '/:id'           => 'projects#update'
  get   '/:id/user_list' => 'projects#user_list', :as => 'user_list'


  resources :users do
  #   resources :tasks
  end

  resources :projects, except: [:show, :update, :patch] do
    member do
      put :leave
    end
  end

  scope '/:project_id', :as => 'project' do
    resources :members, :only => [:index, :create, :destroy], controller: 'project/members'
    resources :conversations, :except => [:edit] do
      member do
        put :mute
      end
      resources :messages, :only => [:create, :update]
    end
    resources :invites, :only => [:create]
    resources :tasks, :only => [:index, :create, :update] do
      resources :doers, :only => [:create, :destroy], controller: 'task/doers'
    end
    get '/unsubscribe/:token' => 'email_subscriptions#unsubscribe', as: 'unsubscribe'
    post '/process_unsubscribe' => 'email_subscriptions#process_unsubscribe'
    get '/subscribe/:token' => 'email_subscriptions#subscribe', as: 'subscribe'
  end

  resources :emails, :only => :create

  root :to => 'homepage#show'

end
