# usage:    bundle exec rake import:json
# optional: BEEHIVE_DATA_ETL_URL=0.tcp.ngrok.io:12345
# optional: SAVE=true

namespace :import do
  desc 'Import grants data from beehive-data-etl'
  task json: :environment do
    require 'mongo'

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

    # start

    client = Mongo::Client.new(
      [ ENV['BEEHIVE_DATA_ETL_URL'] || '127.0.0.1:27017' ],
      database: 'beehive-data'
    )
    collection = client[:grants]

    # .aggregate([ { "$sample": { size: 3 } } ])
    collection.find({ award_date: { :$gte => 10.years.ago.utc }}).limit(50).each do |doc|

      funder = Organisation.where(
        organisation_identifier: doc[:funder_identifier]
      ).first_or_initialize

      funder.assign_attributes(
        name: doc[:funder],
        country: Country.find_by(alpha2: 'GB'),
        publisher: true,
        license: doc[:license]
      )

      funder.save!

      @recipient = Organisation.where(
        organisation_identifier: doc[:recipient][:organisation_identifier]
      ).first_or_initialize

      @grant = Grant.where(grant_identifier: doc[:grant_identifier])
                    .first_or_initialize

      doc[:recipient][:country] = Country.find_by(alpha2: doc[:recipient][:country])
      # TODO: remove once beehive-data-etl updated
      doc[:recipient][:org_type] = Organisation::ORG_TYPE.to_h[doc[:recipient][:org_type]]
      save(@recipient, doc[:recipient].except(:organisation_type, :income, :spending, :volunteers, :employees, :operating_for))

      grant_values = {
        funder:             funder,
        recipient:          @recipient,
        title:              doc[:title],
        description:        doc[:description],
        currency:           doc[:currency],
        funding_programme:  doc[:fund],
        amount_awarded:     doc[:amount_awarded],
        amount_applied_for: doc[:amount_applied_for],
        amount_disbursed:   doc[:amount_disbursed],
        award_date:         doc[:approval_date],
        planned_start_date: doc[:planned_start_date],
        planned_end_date:   doc[:planned_end_date],
        open_call:          doc[:open_call],
        gender:             doc[:beneficiaries][:genders]
      }

      beneficiary_names = doc[:beneficiaries][:beneficiaries].map { |h| h["name"] }
      @grant.beneficiary_ids << Beneficiary.where(sort: beneficiary_names).pluck(:id)

      age_group_labels = doc[:beneficiaries][:ages].map { |h| h["label"] }
      @grant.age_group_ids << AgeGroup.where(label: age_group_labels).pluck(:id)

      save(@grant, grant_values)
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
