Multify::Application.routes.draw do

  devise_for :users

  resources :users do
  #   resources :tasks
  end

  resources :projects, except: [:edit, :show]
  scope '/:project_id', :as => 'project' do
    resources :conversations, :only => [:index, :new, :show, :create] do
      member do
        put :mute
      end
      resources :messages, :only => [:create]
    end
  end
  get '/:project_id/edit' => 'projects#edit', :as => 'edit_project'
  get '/:project_id' => 'projects#show',      :as => 'project'

  post '/:project_id/conversations/:task_id/add_doer' => 'conversations#add_doer', :as => 'add_doer'

  root :to => 'homepage#show'

end
