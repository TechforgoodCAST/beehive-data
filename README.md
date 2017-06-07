# Beehive Data

[![CircleCI](https://circleci.com/gh/TechforgoodCAST/beehive-data.svg?style=svg&circle-token=9257350e2edae45ad5e7fe35d0926338e610574f)](https://circleci.com/gh/TechforgoodCAST/beehive-data)

## Setup

1. `bundle install`
2. `npm install` # install node modules
3. Create `.env` file in root folder (see sample below)
3. `rake db:create db:setup SAVE=true`

## Sample `.env` file

```
DATABASE_URL=postgres://username:password@localhost/beehive-data_development
DATABASE_URL_TEST=postgres://username:password@localhost/beehive-data_test
```

## Import Data

### 1. Import data from a grantnav JSON export or 360 Giving json file.

The whole file can be downloaded from <http://grantnav.threesixtygiving.org/api/grants.json>.

NB it is quite a big file so import may take a long time. You can speed things
up by not including the Big Lottery Fund grants if that is helpful.

`rake import:json FILE=~/path/to/file.json SAVE=true`

### 1b. Import data from a 360 Giving CSV

Alternatively you can import data from a 360 Giving format CSV file. A list of
these can be found in the [360 Giving data registry](http://www.threesixtygiving.org/data/data-registry/)

`rake import:csv FILE=~/path/to/file.csv SAVE=true`

### 2. Add charity data

With a local copy of [charitybase](https://github.com/tithebarn/charity-base)
running (after importing the data into a mongodb database), add data from the
mongodb database about recipient charities.

`rake update:charity CHARITY_BASE_DB_URL=127.0.0.1:27017 SAVE=true`

### 3. Add beneficiary data

Using regular expressions, extract information on the possible beneficiaries of
grants, including beneficiary groups, age groups, etc.

`rake update:beneficiaries SAVE=true`

By default the task will only be run on grants with a state of "import", which
should apply to any that have been importing using steps 1 and 2. The net can be
widened by passing `STATE=import,review` (a comma-separated list of states to include).

Grants have their state set to "review" at the end of this step.

### 4. Add country data

Using regular expressions again add details on the countries and districts that
grants operate in.

`rake update:areas SAVE=true`

Again the `STATE` flag can be used to control which grants are looked at. The
default is "import" and "review" - so capturing any grants included in the
previous 3 steps.

## Meaning of `state`

The `state` variable for a grant tells you how far it is through the import process.

| State    | Grant created | Charity data added | Beneficiaries added | Areas added |
|----------|---------------|--------------------|---------------------|-------------|
| import   | Yes           | Yes                |                     |             |
| review   | Yes           | Yes                | Yes                 |             |
| approved | Yes           | Yes                | Yes                 | Yes         |

## Running tests

`bin/rspec`
