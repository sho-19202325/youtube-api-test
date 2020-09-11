Rails.application.routes.draw do
  get 'user/user_cal'
  get 'home/index'
  devise_for :users, controllers: {
    :omniauth_callbacks => "users/omniauth_callbacks",
  }
  get 'user/show', as: 'user_root'
  root to: 'home#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
