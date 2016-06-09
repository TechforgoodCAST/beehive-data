# usage:    be rake import:add FILE=~/path/to/file.csv
# optional: SAVE=true

namespace :import do
  desc 'Import grants data from file'
  task add: :environment do
    require 'open-uri'
    require 'csv'

    @errors = []
    @counters = {
      valid_organisations:   0,
      invalid_organisations: 0,
      valid_grants:          0,
      invalid_grants:        0
    }

    def obj_name(obj)
      return obj.class.name.downcase
    end

    def save(obj, values, last=false)
      obj.assign_attributes(values)
      obj_name = obj_name(obj)

      if obj.valid?
        print last ? '. ' : '.'
        @counters["valid_#{obj_name}s".to_sym] += 1
        obj.save if ENV['SAVE']
      else
        print last ? '* ' : '*'
        @counters["invalid_#{obj_name}s".to_sym] += 1
        @errors << "#{obj.send("#{obj_name}_identifier")}: #{obj.errors.full_messages}"
      end
    end

    def log(obj)
      obj_name = obj_name(obj)
      puts "#{obj.class.name}s: #{@counters["valid_#{obj_name}s".to_sym]} #{ENV['SAVE'] ? 'saved' : 'valid'}, #{@counters["invalid_#{obj_name}s".to_sym]} invalid"
    end

    CSV.parse(open(ENV['FILE']).read, headers: true) do |row|

      funder     = Organisation.find_by(organisation_identifier: row['Funding Org:Identifier'])
      @recipient = Organisation.find_or_initialize_by(organisation_identifier: row['Recipient Org:Identifier'])
      @grant     = Grant.find_or_initialize_by(grant_identifier: row['Identifier'])

      recipient_values = {
        charity_number:      row['Recipient Org:Charity Number'],
        company_number:      row['Recipient Org:Company Number'],
        organisation_number: row['Recipient Org:Organisation Number'],
        name:                row['Recipient Org:Name'],
        street_address:      row['Recipient Org:Street Address'],
        city:                row['Recipient Org:City'],
        region:              row['Recipient Org:County'],
        postal_code:         row['Recipient Org:Postal Code'],
        country:             Country.find_by(alpha2: row['Recipient Org:Country']),
        website:             row['Recipient Org:Web Address']
      }

      save(@recipient, recipient_values)

      grant_values = {
        funder:             funder,
        recipient:          @recipient,
        title:              row['Title'],
        description:        row['Description'],
        currency:           row['Currency'],
        funding_programme:  row['Grant Programme:Title'],
        amount_awarded:     row['Amount Awarded'],
        amount_applied_for: row['Amount Applied For'],
        amount_disbursed:   row['Amount Disbursed'],
        award_date:         row['Award Date'],
        planned_start_date: row['Planned Dates:Start Date'],
        planned_end_date:   row['Planned Dates:End Date'],
        open_call:          row['From an open call?']
      }

      if countries = row['Beneficiary Location:Country Code']
        grant_values[:countries] = Country.where(alpha2: countries.split(','))
      end
      if districts = row['Beneficiary Location:Name']
        grant_values[:districts] = District.where('name IN (:regions) OR
                                                  region IN (:regions) OR
                                                  sub_country IN (:regions)',
                                                  regions: districts.split(',')
                                                )
      end

      save(@grant, grant_values, true)
    end

    puts "\n\n"
    log(@recipient)
    log(@grant)
    if @errors.count > 0
      puts "\nErrors\n------"
      puts @errors
    end
    puts "\n"

  end
end
