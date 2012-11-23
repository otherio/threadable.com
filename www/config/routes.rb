Www::Application.routes.draw do

  resources :projects, :path => '/' do
    resources :tasks do
      member do
        get 'become_a_doer'
        get 'become_a_follower'
        get 'unsubscribe'
      end
    end
  end

  root :to => "home#index"
end
