Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }
  resources :channels, :messages, :users

  root to: "home#index"

end
