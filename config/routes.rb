Threadable::Application.routes.draw do

  get   '/sign_in'           => 'authentication#show'
  post  '/sign_in'           => 'authentication#sign_in'
  post  '/recover-password'  => 'authentication#recover_password', as: 'recover_password'
  match '/sign_out'          => 'authentication#sign_out', via: [:get, :delete], as: 'sign_out'

  post  '/sign_up' => 'sign_up#sign_up'
  match '/sign_up/confirmation/:token' => 'sign_up#confirmation', via: [:get, :post], as: 'sign_up_confirmation'

  get  '/create' => 'organizations#new',    as: 'new_organization'
  post '/create' => 'organizations#create'

  get  '/ea/:token' => 'email_actions#show', as: 'email_action'
  post '/ea/:token' => 'email_actions#take'

  namespace :api, except: [:new, :edit] do
    scope :users do
      resource :current, controller: 'current_user', only: [:show, :update]
    end

    resources :organizations
    resources :groups do
      post :join
      post :leave
    end
    resources :conversations do
      get :search, on: :collection
    end
    resources :tasks
    resources :messages
    resources :events
    resources :organization_members, only: [:index, :create, :update, :destroy]
    resources :group_members,        only: [:index, :create, :update, :destroy]
    resources :task_doers
  end

  get '/auth/:provider/callback', to: 'external_auth#create'

  # OLD ROUTES START

  get '/admin' => 'admin#show'
  namespace :admin do
    get    'debug'         => 'debug#show'
    get    'debug/enable'  => 'debug#enable'
    get    'debug/disable' => 'debug#disable'

    post   'organizations/:organization_id/members'               => 'organization/members#add',    as: 'add_organization_member'
    get    'organizations/:organization_id/members/:user_id/edit' => 'organization/members#edit',   as: 'edit_organization_member'
    patch  'organizations/:organization_id/members/:user_id'      => 'organization/members#update', as: 'update_organization_member'
    delete 'organizations/:organization_id/members/:user_id'      => 'organization/members#remove', as: 'remove_organization_member'
    get    'organizations'          => 'organizations#index',   as: 'organizations'
    post   'organizations'          => 'organizations#create'
    get    'organizations/new'      => 'organizations#new',     as: 'new_organization'
    get    'organizations/:id/edit' => 'organizations#edit',    as: 'edit_organization'
    patch  'organizations/:id'      => 'organizations#update',  as: 'organization'
    delete 'organizations/:id'      => 'organizations#destroy'
    get    'users'                  => 'users#index',  as: 'users'
    get    'users/:user_id'         => 'users#show',   as: 'user'
    get    'users/:user_id/edit'    => 'users#edit',   as: 'edit_user'
    post   'users/:user_id/merge'   => 'users#merge',  as: 'merge_user'
    patch  'users/:user_id'         => 'users#update', as: 'update_user'

    get    'incoming_emails'           => 'incoming_emails#index',  as: 'incoming_emails'
    get    'incoming_emails/:id'       => 'incoming_emails#show',   as: 'incoming_email'
    post   'incoming_emails/:id/retry' => 'incoming_emails#retry',  as: 'retry_incoming_email'

    get    'outgoing_emails'           => 'outgoing_emails#edit',   as: 'outgoing_emails'
    post   'outgoing_emails/retry'     => 'outgoing_emails#retry',  as: 'retry_outgoing_email'

    constraints AdminConstraint.new do
      require 'sidekiq/web'
      mount Sidekiq::Web => '/background_jobs'
      mount MailPreview => '/mail_preview' if defined?(MailView)
    end
    get '/*anything', to: redirect('/admin')
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

    resources :held_messages, :only => [:index, :show], controller: 'organization/held_messages' do
      post :accept, on: :member
      post :reject, on: :member
    end

    match '/unsubscribe/:token' => 'organization/email_subscriptions#unsubscribe', as: 'unsubscribe', via: [:get, :post]
    match '/resubscribe/:token' => 'organization/email_subscriptions#resubscribe', as: 'resubscribe', via: [:get, :post]
  end

  resources :emails, :only => :create
  resources :mailgun_events, :only => :create

  get '/:organization_id/conversations/:conversation_id', to: redirect('/%{organization_id}/my/conversations/%{conversation_id}')
  get '/:organization_id/tasks/:conversation_id',         to: redirect('/%{organization_id}/my/tasks/%{conversation_id}')

  get '/:organization_id/tasks/:conversation_id/ill_do_it'      => 'old_email_actions#ill_do_it'
  get '/:organization_id/tasks/:conversation_id/remove_me'      => 'old_email_actions#remove_me'
  get '/:organization_id/tasks/:conversation_id/mark_as_done'   => 'old_email_actions#mark_as_done'
  get '/:organization_id/tasks/:conversation_id/mark_as_undone' => 'old_email_actions#mark_as_undone'
  get '/:organization_id/conversations/:conversation_id/mute'   => 'old_email_actions#mute'

  # OLD ROUTES END

  get '/frontpage' => 'homepage#show'
  get '/*path' => 'client_app#show'
  root to: 'homepage#show'

end
