Multify::Application.routes.draw do

  unless Rails.env.production?
    get '/test/javascripts' => 'test/javascripts#show', as: 'javascript_tests'
  end

  namespace :admin do
    mount Resque::Server, :at => "/resque"
  end

  get '/development' => 'development#index'

  # get "users/confirmation" => "confirmations#show", as: 'user_confirmation'
  devise_for :users, :controllers => {
    :registrations => 'registrations',
    :confirmations => 'confirmations',
    :omniauth_callbacks => "users/omniauth_callbacks",
  }

  devise_scope :user do
    get '/thanks-for-signing-up' => 'registrations#thanks', as: 'thanks_for_signing_up'
    put "/users/confirm" => "confirmations#confirm", as: 'user_confirm'
  end

  resources :users do
  #   resources :tasks
  end

  resources :projects, except: [:edit, :show]

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
    get '/subscribe/:token' => 'email_subscriptions#subscribe', as: 'subscribe'
  end

  resources :emails, :only => :create

  get '/:project_id/edit' => 'projects#edit', :as => 'edit_project'
  get '/:project_id' => 'projects#show',      :as => 'project'
  get '/:project_id/user_list' => 'projects#user_list', :as => 'user_list'

  root :to => 'homepage#show'

end
