Www::Application.routes.draw do

  get "/", :to => "home#index", :as => 'root'

  resource :authentication, :only => [:create, :destroy]

  get "/join", :to => "users#new", :as => 'join'
  resources :users, :except => :new

  resources :projects, :path => '/' do
    with_options :only => [:index, :create, :destroy] do |o|

      o.resources :members, :controller => 'projects/members'

      resources :tasks, :controller => 'projects/tasks' do
        o.resources :doers,     :controller => 'projects/tasks/doers'
        o.resources :followers, :controller => 'projects/tasks/followers'
        o.resources :comments,  :controller => 'projects/tasks/comments'
      end
    end
  end


end
