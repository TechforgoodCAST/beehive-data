## Beehive Data

### Setup

1. `bundle install`
2. `rake db:create db:setup SAVE=true`

### Import Data

`rake import:add FILE=~/path/to/file.csv SAVE=true`

### Running tests

`bin/rspec`
