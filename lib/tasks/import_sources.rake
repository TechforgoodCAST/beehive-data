# usage:    bundle exec rake import:sources
# optional: SAVE=true
# optional: FILE=http://data.threesixtygiving.org/data.json

namespace :import do
  desc 'Import grant sources data from 360 Giving JSON feed'
  task sources: :environment do
    require 'json'
    require 'open-uri'

  end
end
