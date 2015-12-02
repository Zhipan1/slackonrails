Rails.application.routes.draw do


  devise_for :users, controllers: { registrations: 'users/registrations'}

  get '/messages/search', to: 'messages#search'

  resources :channels, :messages, :users, :public_channels

  get '/direct_messages/start', to: 'direct_messages#direct_message', as: 'start_direct_message'
  post '/channels/:id/clear', to: 'channels#clear_notification'
  get '/subscribe_to/:channel_id', to: 'application#turbolinks_subscribe_to', as: "subscribe"
  resources :direct_messages



  get '/channels/:channel_id/leave', to: 'channels#user_leave'
  get '/channels/:channel_id/join', to: 'channels#user_join', as: 'join_channel'

  authenticated :user do
    root to: "channels#index", as: 'authenticated'
  end

  devise_scope :user do
    root to: "users/sessions#new"
  end


end
