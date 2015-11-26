Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }
  resources :channels, :messages, :users

  get '/channels/:channel_id/leave', to: 'channels#user_leave'
  get '/channels/:channel_id/join', to: 'channels#user_join', as: 'join_channel'

  root to: "home#index"

end
