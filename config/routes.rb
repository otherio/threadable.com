Multify::Application.routes.draw do

  devise_for :users

  # resources :users do
  #   resources :tasks
  # end

  resources :projects, only: [:index, :new, :create] do
    # resources :tasks
  end
  get    '/:id/edit' => 'projects#edit', :as => 'edit_project'
  get    '/:id' => 'projects#show',      :as => 'project'
  put    '/:id' => 'projects#update'
  delete '/:id' => 'projects#destroy'

  root :to => 'homepage#show'

end
