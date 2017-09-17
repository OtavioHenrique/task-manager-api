Rails.application.routes.draw do
 
  devise_for :users
  namespace :api, defaults: { format: :json  }, constraints: { subdomain: "api" }, path: "/" do
    api_version(:module => "V1", :path => {:value => "v1"}) do
      resources :users, only: [:show]
    end
  end
end
