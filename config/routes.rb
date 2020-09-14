Rails.application.routes.draw do
  get 'user/user_cal'
  get 'home/index'
  devise_for :users, controllers: {
    :omniauth_callbacks => "users/omniauth_callbacks",
  }
  get 'user/show', as: 'user_root'
  root to: 'home#index'
  post 'user/like/:video_id', to: 'user#like'
  post 'user/playlist_item/:video_id', to: 'user#add_playlist_item'
  post 'user/playlist', to: 'user#create_playlist'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
