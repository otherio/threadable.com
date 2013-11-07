Covered::Application.routes.draw do

  unless Rails.env.production?
    get '/test/javascripts' => 'test/javascripts#show', as: 'javascript_tests'
  end

  namespace :admin do
    require 'sidekiq/web'
    mount Sidekiq::Web => '/background_jobs'
    mount MailPreview => '/mail_preview' if defined?(MailView)
  end

  get '/development' => 'development#index'
  get '/demoauth' => 'demo_auth#index', as: 'demo_auth'

  get  '/sign_up'  => 'users#new',              as: 'sign_up'
  get  '/sign_in'  => 'authentication#new',     as: 'sign_in'
  post '/sign_in'  => 'authentication#create'
  get  '/sign_out' => 'authentication#destroy', as: 'sign_out'


  get   '/reset_password/:token' => 'users/reset_password#show', as: 'reset_password'
  patch '/reset_password/:token' => 'users/reset_password#reset'
  post  '/reset_password'        => 'users/reset_password#request_link', as: 'request_reset_password_link'

  resources :users, except: [:new, :destroy] do
    collection do
      get   'setup/:token' => 'users/setup#edit', as: 'setup'
      patch 'setup/:token' => 'users/setup#update'
      get   'confirm/:token' => 'users/confirm#confirm', as: 'confirm'
    end
  end

  scope '/:project_id', :as => 'project' do
    resources :members, :only => [:index, :create, :destroy], controller: 'project/members'

    resources :conversations, :except => [:edit] do
      # member do
      #   put :mute
      # end
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

  get   '/projects'      => 'projects#index'
  get   '/:id/edit'      => 'projects#edit',      :as => 'edit_project'
  get   '/:id'           => 'projects#show',      :as => 'project'
  put   '/:id'           => 'projects#update'
  patch '/:id'           => 'projects#update'
  get   '/:id/user_list' => 'projects#user_list', :as => 'user_list'

  resources :projects, except: [:show, :update, :patch] do
    member do
      put :leave
    end
  end

  root :to => 'homepage#show'

end
