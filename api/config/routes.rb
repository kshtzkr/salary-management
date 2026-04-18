Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post   "auth/login",  to: "auth#create"
      post   "auth/logout", to: "auth#destroy"
      get    "auth/me",     to: "auth#show"

      resources :employees, only: %i[index show create update destroy] do
        post :restore, on: :member
      end

      resources :users, only: %i[index create update destroy]

      namespace :insights do
        get :overview
        get :job_titles
      end
    end
  end
end
