Covered::Application.routes.draw do

  unless Rails.env.production?
    get '/test/javascripts' => 'test/javascripts#show', as: 'javascript_tests'
  end

  namespace :admin do
    require 'resque/server'
    mount Resque::Server, :at => "/resque"
    mount MailPreview => '/mail_preview' if defined?(MailView)
  end

  get '/development' => 'development#index'
  get '/demoauth' => 'demo_auth#index', as: 'demo_auth'

  get   '/setup' => 'users#setup', as: 'user_setup'

  get   '/projects'      => 'projects#index'
  get   '/:id/edit'      => 'projects#edit',      :as => 'edit_project'
  get   '/:id'           => 'projects#show',      :as => 'project'
  put   '/:id'           => 'projects#update'
  patch '/:id'           => 'projects#update'
  get   '/:id/user_list' => 'projects#user_list', :as => 'user_list'


  resources :users do
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

    # resources :invites, :only => [:create]

    resources :tasks, :only => [:index, :create, :update] do
      resources :doers, :only => [:create, :destroy], controller: 'task/doers'


      match 'ill_do_it', via: [:get, :post]
      match 'remove_me', via: [:get, :post]
      match 'mark_as_done', via: [:get, :post]
      match 'mark_as_undone', via: [:get, :post]
    end

    match '/unsubscribe/:token' => 'project/email_subscriptions#unsubscribe', as: 'unsubscribe', via: [:get, :post]
    match '/resubscribe/:token' => 'project/email_subscriptions#resubscribe', as: 'resubscribe', via: [:get, :post]
  end

  resources :emails, :only => :create

  root :to => 'homepage#show'

end
