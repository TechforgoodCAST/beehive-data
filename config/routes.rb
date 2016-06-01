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
  resources :grants, only: [:edit, :update, :index] do
    collection do
      get   '/review', to: 'grants#review'
      patch '/review', to: 'grants#scrape', as: 'scrape'
    end
  end

  # API
  namespace :v1 do
    get '/funders', to: 'funders#index'
    get '/grants/(:year)', to: 'grants#by_year'
    get '/grants/(:year)/(:funder)', to: 'grants#by_funder'
    get '/grants/(:year)/(:funder)/(:programme)', to: 'grants#by_programme'
  end

end
