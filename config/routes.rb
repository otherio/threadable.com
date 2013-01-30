Multify::Application.routes.draw do

  devise_for :users

  resources :users do
  #   resources :tasks
  end

  resources :projects, except: [:edit, :show]
  scope '/:project_id' do
    resources :conversations, :only => [:index, :show, :create] do
      member do
        put :mute
      end
    end
  end
  get '/:project_id/edit' => 'projects#edit', :as => 'edit_project'
  get '/:project_id' => 'projects#show',      :as => 'project'

  root :to => 'homepage#show'

end
