Covered::Application.routes.draw do

  post '/sign_in'  => 'authentication#create'
  post '/sign_out' => 'authentication#destroy'

  namespace :api, except: [:new, :edit] do
    scope :users do
      resource :current, controller: 'current_user', only: [:show, :update]
    end

    resources :organizations
    resources :groups
    resources :conversations
    resources :tasks
    resources :messages
    resources :events

    resources :members, only: [:index]
    resources :task_doers
  end

  # OLD ROUTES START

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

  # OLD ROUTES START

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

    resources :held_messages, :only => [:index], controller: 'organization/held_messages' do
      post :accept, on: :member
      post :reject, on: :member
    end

    match '/unsubscribe/:token' => 'organization/email_subscriptions#unsubscribe', as: 'unsubscribe', via: [:get, :post]
    match '/resubscribe/:token' => 'organization/email_subscriptions#resubscribe', as: 'resubscribe', via: [:get, :post]
  end

  resources :emails, :only => :create

  resources :organizations, except: [:index, :show] do
    member do
      put :leave
    end
  end

  # OLD ROUTES END

  match '/*path' => 'frontend#show', via: [:get, :post, :patch, :delete]
  root to: 'frontend#show', via: [:get, :post, :patch, :delete]

end
