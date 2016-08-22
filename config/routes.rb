Rails.application.routes.draw do

  root 'home#home'
  get '/examples', to: 'home#examples', as: 'examples'

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
  namespace :v1, constraints: { format: 'json' } do
    get '/funders', to: 'funders#index'
    get '/grants/(:year)', to: 'grants#by_year'
    get '/grants/(:year)/(:funder)', to: 'grants#by_funder'
    get '/grants/(:year)/(:funder)/(:programme)', to: 'grants#by_programme'

    # TODO: use recent grants instead of annual for beehive-giving analysis
    # get '/recent_grants/(:funder)', to: 'grants#recent_by_funder'

    get '/demo/funders/(:year)', to: 'examples#funders_by_year'
    get '/demo/grants/(:year)', to: 'examples#grants_by_year', as: 'examples_by_year'

    get '/insight/grants', to: 'integrations#insight_grants'
    get '/integrations/amounts', to: 'integrations#amounts', as: 'amounts'
    get '/integrations/durations', to: 'integrations#durations', as: 'durations'
  end

  # Docs
  get '/docs/moderators', to: 'docs#moderators'

end
