Rails.application.routes.draw do


  devise_for :users, controllers: { registrations: 'users/registrations'}

  get '/messages/search', to: 'messages#search'

  resources :channels, :messages, :users


  get '/channels/:channel_id/leave', to: 'channels#user_leave'
  get '/channels/:channel_id/join', to: 'channels#user_join', as: 'join_channel'

  authenticated :user do
    root to: "home#index", as: 'authenticated'
  end

  devise_scope :user do
    root to: "users/sessions#new"
  end


end
