Rails.application.routes.draw do
  devise_for :users
  resources :channels, :messages, :users

  root to: "home#index"

end
