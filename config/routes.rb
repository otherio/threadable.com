Multify::Application.routes.draw do

  unless Rails.env.production?
    get '/test/javascripts' => 'test/javascripts#show', as: 'javascript_tests'
  end

  get '/development' => 'development#index'

  devise_for :users

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
      resources :messages, :only => [:create]
    end
    resources :invites, :only => [:create]
    resources :tasks, :only => [:index, :create] do
      resources :doers, :only => [:create, :destroy], controller: 'task/doers'
    end
  end

  get '/:project_id/edit' => 'projects#edit', :as => 'edit_project'
  get '/:project_id' => 'projects#show',      :as => 'project'
  get '/:project_id/user_list' => 'projects#user_list', :as => 'user_list'

  root :to => 'homepage#show'

end
