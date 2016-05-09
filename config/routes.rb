Rails.application.routes.draw do

  devise_for :users
  root 'home#index'

  get '/grants', to: 'grants#index'
  post '/grants', to: 'grants#create'

  resources :organisations, :funders, :recipients, shallow: true do
    resources :grants
  end

end
