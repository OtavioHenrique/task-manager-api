Rails.application.routes.draw do
 
  devise_for :users, only: [:sessions], controllers: { sessions: 'api/v1/sessions' }

  namespace :api, defaults: { format: :json  }, constraints: { subdomain: "api" }, path: "/" do
    api_version(:module => "V1", :path => {:value => "v1"}) do
      resources :users, only: [:show, :index, :create, :update, :destroy]
      resources :sessions, only: [:create, :destroy]
      resources :tasks, only: [:index]
    end
  end
end
