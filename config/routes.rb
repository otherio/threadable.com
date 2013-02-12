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
    resources :members, :only => [:index], controller: 'project/members'
    resources :conversations, :only => [:index, :new, :show, :create] do
      member do
        put :mute
      end
      resources :messages, :only => [:create]
    end
  end
  get '/:project_id/edit' => 'projects#edit', :as => 'edit_project'
  get '/:project_id' => 'projects#show',      :as => 'project'
  get '/:project_id/user_list' => 'projects#user_list', :as => 'user_list'

  post '/:project_id/conversations/:task_id/add_doer' => 'conversations#add_doer', :as => 'add_doer'
  post '/:project_id/tasks' => 'conversations#create_as_task', :as => 'create_as_task'

  root :to => 'homepage#show'

end
