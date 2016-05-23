Rails.application.routes.draw do

  root 'home#index'

  # Admin
  devise_for :users
  resources :organisations, only: [:edit, :update, :index] do
    collection do
      get   '/review', to: 'organisations#review'
      patch '/review', to: 'organisations#scrape', as: 'scrape'
    end
  end

  # API
  namespace :v1 do
    get '/funders', to: 'funders#index'
  end

  # TODO: refactor
  get '/grants', to: 'grants#index'
  post '/grants', to: 'grants#create'

end
