Multify::Application.routes.draw do

  devise_for :users

  # get  '/login' => 'sessions#new', :as => 'login'
  # resource :session, :only => [:create, :destry]

  # resources :users do
  #   resources :tasks
  # end

  # resources :projects, except: :show do
  #   resources :tasks
  # end
  # match '/:id' => 'projects#show', :as => 'project'


  root :to => 'homepage#show'

end
