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

    # get charity commission lookups
    ccareas = {}
    CSV.foreach(Rails.root.join('lib', 'assets', 'csv', 'cc-aoo-gss-iso.csv'), headers: true) do |row|
      ccareas["#{row["aootype"]}#{row["aookey"]}"] = row.to_hash
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

      # get details about recipients
      doc[:recipientOrganization].each do |r|

        char_comp = get_charity_and_company( r[:charityNumber], r[:companyNumber], charitybase )
        r[:charity] = char_comp[0]
        r[:company] = char_comp[1]

        # get charity beneficiaries
        r[:beneficiaries] = get_charity_beneficiaries(r[:charity])

        # get countries
        r[:countries] = []
        r[:districts] = []
        if r[:charity]
          r[:charity].fetch("areaOfOperation", [{}]).each do |aoo|
            if aoo["aooType"]=="D"
              r[:countries] << ccareas["#{aoo["aooType"]}#{aoo["aooKey"]}"]["ISO3166-1"]
            elsif ['A','B','C'].include? aoo["aooType"]
              r[:countries] << 'GB'
              district_code = ccareas["#{aoo["aooType"]}#{aoo["aooKey"]}"]["oldCode"]
              # Old ONS codes are used.
              # If it's a 2 digit code that means it's a country, which aren't in the database, so instead
              # we'll check a regex for districts where the first two digits are the country.
              if district_code.length==2
                r[:districts].concat @districts.select{ |d| d[:subdivision] =~ /#{district_code}[A-Z]{2}/ && d[:country_id] == gb_id }
              else
                r[:districts].concat @districts.select{ |d| d[:subdivision] == district_code && d[:country_id] == gb_id }
              end
            end

          end
        end
      end

      # bail if grant to individual
      if doc[:recipientOrganization][0][:org_type] == -1
        @counters[:skipped_individual] += 1
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
        org_type:                doc[:recipientOrganization][0][:org_type],
        multi_national:          doc[:recipientOrganization][0][:countries].count > 1, # TODO find actual multi_national value
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
        income:             doc[:recipientOrganization][0][:financial][:income].presence || -1,
        spending:           doc[:recipientOrganization][0][:financial][:spending].presence || -1,
        volunteers:         doc[:recipientOrganization][0][:financial][:volunteers].presence || -1,
        employees:          doc[:recipientOrganization][0][:financial][:employees].presence || -1,
        operating_for:      doc[:recipientOrganization][0][:operating_for].presence || -1,
        state:              "approved",
      }

      desc = "#{doc[:title]} #{doc[:description]}"

      genders = GENDER_REGEXES.select{|gender, reg| desc =~ reg }.keys.uniq
      if genders.count==1
        grant_values[:gender] = genders[0].to_s
      end
      if genders.count==0
        @counters[:default_gender] += 1
      end

      ben_names = BEN_REGEXES.select {|ben, reg| desc =~ reg }.keys
      ben_names.concat doc[:recipientOrganization][0][:beneficiaries]
      @grant.beneficiary_ids = Beneficiary.where(sort: ben_names.uniq).pluck(:id)

      if @grant.beneficiary_ids.count ==0
        grant_values[:state] = "review"
        @counters[:default_beneficiaries] += 1
        if ben_names.count > 0
          @counters[:wider_beneficiaries] += 1
        end
      end

      # check if affect people or others
      ['People', 'Other'].each do |g|
        ids = Beneficiary.where(group: g).pluck(:id)
        grant_values["affect_#{g.downcase}".to_sym] = (@grant.beneficiary_ids & ids).count > 0
      end
      if grant_values[:affect_people]==false
        grant_values[:affect_other]=true
      end

      # get any ages from the description
      age_groups = []
      # use a regex to look for age ranges first
      ages = desc.scan(/\b(age(d|s)? ?(of|betweee?n)?|adults)? ?([0-9]{1,2}) ?(\-|to) ?([0-9]{1,2}) ?\-?(year\'?s?[ -](olds)?|y\.?o\.?)?\b/i)
      if ages.count > 0
        ages.each do |age|
          if (age[0] || age[1] || age[2] || age[6] || age[7] || age[4]=="to")
            age_groups << [age[3].to_i, age[5].to_i]
          end
        end
      end

      # then look in description for terms using regex
      ages = AGE_REGEXES.select {|title, age| desc =~ age[:regex]}
      ages.each do |title, age|
        age_groups << [age[:age_from], age[:age_to]]
      end

      age_group_labels = []
      age_groups.each do |age|
        age_group_labels.concat AGE_CATEGORIES.select {|age_cat| age[0] <= age_cat[:age_to] && age_cat[:age_from] <= age[1] && age_cat[:label]!= "All ages"}
      end
      age_group_labels = age_group_labels.uniq.map{|age| age[:label]}

      # default to All ages
      if age_group_labels.empty?
        age_group_labels = ["All ages"]
        @counters[:default_age] += 1
      end

      @grant.age_group_ids = AgeGroup.where(label: age_group_labels).pluck(:id)

      # Find countries mentioned
      grant_values[:countries] = []

      # Using regexes
      @countries.each do |country|
        # special case for Northern Ireland
        country_desc = desc.gsub(/\bNorthern Ireland\b/i, '')

        if country_desc =~ /\b#{country[:name]}\b/i
          grant_values[:countries] << country[:alpha2]
        end

        country[:altnames].each do |altname|
          if country_desc =~ /\b#{altname}\b/i
            grant_values[:countries] << country[:alpha2]
          end
        end
      end

      # using data from the grant
      doc.fetch(:beneficiaryLocation, [{}]).each do |location|
        if location.fetch(:countryCode, nil)
          grant_values[:countries] << location.fetch(:countryCode)
        end
      end

      # Using charity commission data
      if grant_values[:countries].count==0
        if doc[:recipientOrganization][0][:countries].empty?
          grant_values[:countries] = ["GB"]
          @counters[:default_country] += 1
        else
          grant_values[:countries] = doc[:recipientOrganization][0][:countries]
        end
      end

      # get districts
      grant_values[:districts] = []

      if grant_values[:districts].count==0
        if doc[:recipientOrganization][0][:districts].empty?
          # use all districts for country
          #grant_values[:countries].each do |c|
          #  grant_values[:districts].concat @districts.select { |d| d[:country_id] == c[:id] }
          #end
        else
          # get districts from charity
          grant_values[:districts] = doc[:recipientOrganization][0][:districts]
          grant_values[:countries].concat doc[:recipientOrganization][0][:countries]
        end
      end

      grant_values[:countries] = @countries.select { |country| country[:alpha2].in?(grant_values[:countries]) }

      if grant_values[:countries].count > 1
        grant_values["geographic_scale"] = 3
      elsif grant_values[:countries].count == 1 && grant_values[:districts].count == 0
        grant_values["geographic_scale"] = 2
      elsif grant_values[:districts].count > 1
        grant_values["geographic_scale"] = 1
      else
        grant_values["geographic_scale"] = 0
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
