Rails.application.routes.draw do
  root "properties#index"

  resources :properties, only: [ :index, :show ] do
    resources :photos, only: [ :show ], params: :filename
  end

  get "/photos/:property_id/:filename", to: "photos#show", as: :photo,
    constraints: { filename: /[^\/]+/ }

  get "up" => "rails/health#show", as: :rails_health_check
end
