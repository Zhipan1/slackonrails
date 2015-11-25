Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }
  resources :channels, :messages, :users

  get '/channels/:channel_id/join', to: 'channels#user_join'

  root to: "home#index"

end
