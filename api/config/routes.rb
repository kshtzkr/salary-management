Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post "auth/login", to: "auth#create"
      get  "auth/me",    to: "auth#show"
    end
  end
end
