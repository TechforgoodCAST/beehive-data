source 'https://rubygems.org'

ruby '2.3.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.6'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.15'
# Use Passenger as the app server
gem 'passenger', '>= 5.0.25', require: 'phusion_passenger/rack_handler'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

gem 'haml'

gem 'semantic-ui-sass', '~> 2.2', github: 'doabit/semantic-ui-sass'
gem 'devise'
gem 'workflow'
gem 'nokogiri'
gem 'simple_form'

gem 'rails_12factor', group: :production
# Use jquery as the JavaScript library
gem 'jquery-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

group :development, :test do
  gem 'byebug'
  gem 'rspec-rails', '~> 3.0'
  gem 'guard-rspec', require: false
end

group :development do
  gem 'quiet_assets'
  gem 'web-console', '~> 2.0'
  gem 'spring'
end

group :test do
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'mocha'
end
