Rails.application.routes.draw do

  devise_for :users
  root 'home#index'

  get '/grants', to: 'grants#index'
  post '/grants', to: 'grants#create'

  namespace :v1 do
    get '/funders', to: 'funders#index'
  end

end
