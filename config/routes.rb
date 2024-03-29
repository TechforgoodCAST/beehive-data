Rails.application.routes.draw do

  mount ForestLiana::Engine => '/forest'
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
  get '/status', to: 'funds#status', as: 'status'

  # API
  namespace :v1, constraints: { format: 'json' } do
    # Public
    get '/funders', to: 'funders#index'
    get '/grants/(:year)', to: 'grants#by_year'
    get '/grants/(:year)/(:funder)', to: 'grants#by_funder'
    get '/grants/(:year)/(:funder)/(:programme)', to: 'grants#by_programme'

    # TODO: use recent grants instead of annual for beehive-giving analysis
    # get '/recent_grants/(:funder)', to: 'grants#recent_by_funder'

    # Demo
    get '/demo/funders/(:year)', to: 'examples#funders_by_year'
    get '/demo/grants/(:year)', to: 'examples#grants_by_year', as: 'examples_by_year'

    # Private
    get '/integrations/beneficiaries', to: 'integrations#beneficiaries', as: 'beneficiaries'
    get '/integrations/amounts', to: 'integrations#amounts', as: 'amounts'
    get '/integrations/durations', to: 'integrations#durations', as: 'durations'
    get '/integrations/fund_summary/(:fund_slug)', to: 'integrations#fund_summary', as: 'fund_summary'
  end

  # Docs
  get '/docs/moderators', to: 'docs#moderators'

end
