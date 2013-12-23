Covered::Application.routes.draw do

  unless Rails.env.production?
    get '/test/javascripts' => 'test/javascripts#show', as: 'javascript_tests'
  end

  get '/admin' => 'admin#show'
  namespace :admin do
    post   'organizations/:organization_id/members'          => 'organization/members#add',    as: 'add_organization_member'
    patch  'organizations/:organization_id/members/:user_id' => 'organization/members#update', as: 'update_organization_member'
    delete 'organizations/:organization_id/members/:user_id' => 'organization/members#remove', as: 'remove_organization_member'
    get    'organizations'          => 'organizations#index',   as: 'organizations'
    post   'organizations'          => 'organizations#create'
    get    'organizations/new'      => 'organizations#new',     as: 'new_organization'
    get    'organizations/:id/edit' => 'organizations#edit',    as: 'edit_organization'
    patch  'organizations/:id'      => 'organizations#update',  as: 'organization'
    delete 'organizations/:id'      => 'organizations#destroy'

    get    'incoming_emails'           => 'incoming_emails#index',  as: 'incoming_emails'
    get    'incoming_emails/:id'       => 'incoming_emails#show',   as: 'incoming_email'
    post   'incoming_emails/:id/retry' => 'incoming_emails#retry',  as: 'retry_incoming_email'

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
    end
  end

  get   '/profile' => 'profile#show'
  patch '/profile' => 'profile#update'
  post  '/email_addresses' => 'email_addresses#create', as: 'email_addresses'
  patch '/email_addresses' => 'email_addresses#update', as: 'email_address'
  post  '/email_addresses/resend_confirmation_email' => 'email_addresses#resend_confirmation_email', as: 'resend_email_address_confirmation'
  match '/email_addresses/confirm/:token' => 'email_addresses#confirm', as: 'confirm_email_address', via: [:get, :post]

  scope '/:organization_id', :as => 'organization' do
    resources :members, :only => [:index, :create, :destroy], controller: 'organization/members'

    resources :conversations, :except => [:edit] do
      member do
        match 'mute', via: [:get, :post]
        match 'unmute', via: [:post]
      end
      resources :messages, :only => [:create, :update]
    end

    resources :held_messages, :only => [:index], controller: 'organization/held_messages' do
      post :accept, on: :member
      post :reject, on: :member
    end

    # resources :invites, :only => [:create]

    resources :tasks, :only => [:index, :create, :update] do
      post   'doers'          => 'task/doers#add',    as: 'doers'
      delete 'doers/:user_id' => 'task/doers#remove', as: 'doer'

      match 'ill_do_it', via: [:get, :post]
      match 'remove_me', via: [:get, :post]
      match 'mark_as_done', via: [:get, :post]
      match 'mark_as_undone', via: [:get, :post]
    end

    match '/unsubscribe/:token' => 'organization/email_subscriptions#unsubscribe', as: 'unsubscribe', via: [:get, :post]
    match '/resubscribe/:token' => 'organization/email_subscriptions#resubscribe', as: 'resubscribe', via: [:get, :post]
  end

  resources :emails, :only => :create

  get   '/:id/edit'      => 'organizations#edit',      :as => 'edit_organization'
  get   '/:id'           => 'organizations#show',      :as => 'organization'
  put   '/:id'           => 'organizations#update'
  patch '/:id'           => 'organizations#update'
  get   '/:id/user_list' => 'organizations#user_list', :as => 'user_list'

  resources :organizations, except: [:index, :show, :update, :patch] do
    member do
      put :leave
    end
  end

  root :to => 'homepage#show'

end
