# usage:    bundle exec rake import:json
# optional: SAVE=true
# optional: SAMPLE=0
# optional: FILE=grantnav.json

namespace :import do
  desc 'Import grants data from 360 Giving JSON file'
  task json: :environment do
    require 'mongo'
    require 'json'
    require 'open-uri'
    require_relative '../assets/swap_funds.rb'

    @errors = []
    @counters = {
      valid_organisations:   0,
      invalid_organisations: 0,
      valid_grants:          0,
      invalid_grants:        0,
      skipped_year:          0,
      skipped_individual:    0,
      default_age:           0,
      default_beneficiaries: 0,
      wider_beneficiaries:   0,
      default_gender:        0,
      default_country:       0,
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

    # get JSON file
    file = open(ENV["FILE"] || "grantnav.json").read
    grant_file = JSON.parse(file, {:symbolize_names => true})
    puts "Loaded #{grant_file[:grants].count} grants"
    if (ENV["SAMPLE"].to_i || 0) > 0
      puts "Sampling #{[ENV["SAMPLE"].to_i, grant_file[:grants].count].min} grants"
      collection = grant_file[:grants].sample(ENV["SAMPLE"].to_i).shuffle
    else
      collection = grant_file[:grants]
    end

    # get district lookups
    @countries = Country.all.to_a
    @districts = District.all.to_a
    gb_id = Country.find_by(alpha2: 'GB')[:id]
    #@country_districts = District.includes(:country).all.group_by{ |d| d.country[:alpha2] }
    grants = []
    recipients = []

    collection.each do |doc|

      # find funder details
      funder = Organisation.where(
        organisation_identifier: doc[:fundingOrganization][0][:id]
      ).first_or_initialize

      funder.assign_attributes(
        name: doc[:fundingOrganization][0][:name],
        country: @countries.select { |country| country[:alpha2] == "GB" }[0],
        publisher: true
      )

      funder.save!

      # convert dates
      doc[:awardDate] = Date.parse(doc[:awardDate])
      if doc[:dateModified]
        doc[:dateModified] = DateTime.parse(doc[:dateModified])
      end

      doc.fetch(:plannedDates, [{}]).each do |d|
        [:endDate, :startDate].each do |se|
          if d[se]
            d[se] = DateTime.parse(d[se])
          end
        end
      end

      # bail if award date too early
      if not Grant::VALID_YEARS.include?(doc[:awardDate].year)
        @counters[:skipped_year] += 1
        next
      end

      @recipient = Organisation.where(
        "organisation_identifier = ? or charity_number = ? or company_number = ?",
        doc[:recipientOrganization][0][:id],
        doc[:recipientOrganization][0][:charityNumber].presence,
        doc[:recipientOrganization][0][:companyNumber].presence
      ).first_or_initialize

      recipient_values = {
        organisation_identifier: doc[:recipientOrganization][0][:id].presence,
        charity_number:          doc[:recipientOrganization][0][:charityNumber].presence,
        company_number:          doc[:recipientOrganization][0][:companyNumber].presence,
        organisation_number:     doc[:recipientOrganization][0][:id].presence,
        name:                    doc[:recipientOrganization][0][:name].presence,
        street_address:          doc[:recipientOrganization][0][:street_address].presence,
        city:                    doc[:recipientOrganization][0][:city].presence,
        region:                  doc[:recipientOrganization][0][:region].presence,
        postal_code:             doc[:recipientOrganization][0][:postalCode].presence,
        country:                 @countries.select { |country| country[:alpha2] == doc[:recipientOrganization][0].fetch(:country, 'GB') }[0],
        website:                 doc[:recipientOrganization][0][:url].presence,
        state:                   'import',
      }

      save(@recipient, recipient_values)

      @grant = Grant.includes(:districts)
                    .where(grant_identifier: doc[:id])
                    .first_or_initialize

      grant_programme = doc.fetch(:grantProgramme, [{}])[0].fetch(:title, "Main Fund")
      if SWAP_FUNDS.fetch(doc[:fundingOrganization][0][:name], nil).class==String
        grant_programme = "Main Fund"
      elsif SWAP_FUNDS.fetch(doc[:fundingOrganization][0][:name], {}).fetch(grant_programme, nil)
        grant_programme = SWAP_FUNDS.fetch(doc[:fundingOrganization][0][:name], {}).fetch(grant_programme, nil)
      end

      grant_values = {
        funder:             funder,
        recipient:          @recipient,
        title:              doc[:title],
        description:        doc[:description],
        currency:           doc[:currency] || "GBP",
        funding_programme:  grant_programme,
        amount_awarded:     doc[:amountAwarded].to_i,
        amount_applied_for: doc[:amountAppliedFor].to_i,
        amount_disbursed:   doc[:amountDisbursed].to_i,
        award_date:         doc[:awardDate],
        planned_start_date: doc.fetch(:plannedDates, [{}])[0].fetch(:startDate, nil),
        planned_end_date:   doc.fetch(:plannedDates, [{}])[0].fetch(:endDate, nil),
        open_call:          doc[:fromOpenCall]=="Yes",
        gender:             "All genders",
        license:            doc.fetch(:dataset, {}).fetch(:license, nil),
        source:             doc.fetch(:dataset, {}).fetch(:distribution, [{}])[0].fetch(:accessURL, nil),
        state:              'import',
        countries:          [],
      }

      # using data from the grant
      doc.fetch(:beneficiaryLocation, [{}]).each do |location|
        if location.fetch(:countryCode, nil)
          grant_values[:countries].concat @countries.select { |country| country[:alpha2].in?( location.fetch(:countryCode) ) }
        end
      end

      save(@grant, grant_values, true)

    end

    puts "\n\n"
    puts "Skipped: #{@counters[:skipped_year]} grants due to the year"
    puts "Skipped: #{@counters[:skipped_individual]} grants as to individuals"
    puts "Default: #{@counters[:default_age]} grants given default age \"All ages\""
    puts "Default: #{@counters[:default_gender]} grants given default gender \"All genders\""
    puts "Default: #{@counters[:default_country]} grants given default country \"GB\""
    puts "Default: #{@counters[:default_beneficiaries]} grants given default beneficaries (#{@counters[:wider_beneficiaries]} would be captured with wider categories)"

    log(@recipient)
    log(@grant)
    if @errors.count > 0
      puts "\nErrors\n------"
      puts @errors
    end
    puts "\n"
  end
end
