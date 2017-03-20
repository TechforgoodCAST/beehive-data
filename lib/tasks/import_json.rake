# usage:    bundle exec rake import:json
# optional: CHARITY_BASE_DB_URL=0.tcp.ngrok.io:12345
# optional: SAVE=true
# optional: SAMPLE=0
# optional: GRANTNAV_FILE=grantnav.json

namespace :import do
  desc 'Import grants data from beehive-data-etl'
  task json: :environment do
    require 'mongo'
    require 'json'

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

    # charity utilities
    def get_charity_and_company( charno, compno)
      charity = nil
      company = nil

      # first check if charty or company exists
      charity = get_charity( charno )
      company = get_company( compno )

      # if the charity exists but company doesn't check for company based on charity
      if(charity && company.nil?)
        company = get_company_from_charity(charity)

      # if the company exists but the charity doesn't check for charity based on company
      if(charity.nil? && company)
        charity = get_charity_from_company(company)

      return [charity, company]
    end

    def parseCharityNumber(regno)
      if regno.nil?
        return nil
      end

      regno = regno.to_s.strip.upcase
      regno.sub!('NO.', '')
      regno.sub!('GB-CHC-', '')
      regno.sub!('GB-COH-', '')
      regno.sub!(' ', '')
      regno.sub!('O', '0')

      if regno.empty?
        return nil
      end

      if regno[0..2]!="SC"
        begin
          regno = Integer(regno)
        rescue ArgumentError
        end
      end

      return regno

    end

    def get_charity( charno, cdb )
      charno = parseCharityNumber(charno)
      if charno
        return cdb[:charities].find_one({"charityNumber" => { :$in => [charno, charno.to_s]}, "subNumber" => 0 } )
      end
    end

    def get_company( compno )

    end

    # start

    # get JSON file
    file = File.read(ENV["GRANTNAV_FILE"] || "grantnav.json")
    grantnav = JSON.parse(file, {:symbolize_names => true})
    puts grantnav[:grants].count
    if ENV["SAMPLE"].to_i || 0 > 0
      puts "Sampling #{ENV["SAMPLE"].to_i} grants"
      collection = grantnav[:grants].sample(ENV["SAMPLE"].to_i)
    else
      collection = grantnav["grants"]
    end

    charitybase = Mongo::Client.new(
      [ ENV['CHARITY_BASE_DB_URL'] || '127.0.0.1:27017' ],
      database: 'charity-base'
    )

    collection.each do |doc|

      # find funder details
      funder = Organisation.where(
        organisation_identifier: doc[:fundingOrganization][0][:id]
      ).first_or_initialize

      funder.assign_attributes(
        name: doc[:fundingOrganization][0][:name],
        country: Country.find_by(alpha2: 'GB'),
        publisher: true
      )

      funder.save!

      # convert dates
      doc[:awardDate] = Date.parse(doc[:awardDate])
      doc[:dateModified] = DateTime.parse(doc[:dateModified])

      # get details about recipients
      doc[:recipientOrganization].each do |recipient|
        byebug
      end


      @recipient = Organisation.where(
        "organisation_identifier = ? or charity_number = ? or company_number = ?",
        doc[:recipientOrganization][0][:id],
        doc[:recipientOrganization][0][:charityNumber].presence,
        doc[:recipientOrganization][0][:companyNumber].presence
      ).first_or_initialize

      byebug
    end


    #collection = client[:grants]
    #filters = { "award_year": { :$gte => 10.years.ago.year }, "recipient.org_type": { :$ne => "An individual"} }
    #filters["recipient.organisation_identifier"] = "GB-CHC-800862"

    collection.each do |doc|

      #if doc[:recipient][:website] !~ URI::regexp(%w(http https))
      #  if doc[:recipient][:website].present? and "http://" + doc[:recipient][:website] =~ URI::regexp(%w(http https))
      #    doc[:recipient][:website] = "http://" + doc[:recipient][:website]
      #  else
      #    doc[:recipient][:website] = nil
      #  end
      #end
#

#
      #
#

#
      #@grant = Grant.where(grant_identifier: doc[:grant_identifier])
      #              .first_or_initialize
#
      #doc[:recipient][:country] = Country.find_by(alpha2: doc[:recipient][:country])
      ## TODO: remove once beehive-data-etl updated
      #doc[:recipient][:postal_code] = doc[:recipient][:postal_code].presence || "Unknown" # TODO: Best way to treat missing postcodes?
      #doc[:recipient][:org_type] = Organisation::ORG_TYPE.to_h[doc[:recipient][:org_type]]
      #doc[:recipient][:multi_national] = doc[:recipient][:multi_national] || false
      #save(@recipient, doc[:recipient].except(:income, :spending, :volunteers, :employees, :operating_for))
#
      #grant_values = {
      #  funder:             funder,
      #  recipient:          @recipient,
      #  title:              doc[:title],
      #  description:        doc[:description],
      #  currency:           doc[:currency],
      #  funding_programme:  doc[:funding_programme].presence || "Main Fund",
      #  amount_awarded:     doc[:amount_awarded],
      #  amount_applied_for: doc[:amount_applied_for],
      #  amount_disbursed:   doc[:amount_disbursed],
      #  award_date:         doc[:award_date],
      #  planned_start_date: doc[:planned_start_date],
      #  planned_end_date:   doc[:planned_end_date],
      #  open_call:          doc[:open_call],
      #  gender:             doc[:beneficiaries][:genders],
      #  license:            doc[:license],
      #  source:             doc[:source],
      #  income:             Grant::INCOME.to_h[ doc[:income].presence || "Unknown" ],
      #  spending:           Grant::INCOME.to_h[ doc[:spending].presence || "Unknown" ],
      #  volunteers:         Grant::EMPLOYEES.to_h[ doc[:volunteers].presence || "Unknown" ],
      #  employees:          Grant::EMPLOYEES.to_h[ doc[:employees].presence || "Unknown" ],
      #  operating_for:      doc[:operating_for]
      #}
#
      #beneficiary_names = doc[:beneficiaries][:beneficiaries].map { |h| h["name"] }
      #@grant.beneficiary_ids << Beneficiary.where(sort: beneficiary_names).pluck(:id)
#
      #age_group_labels = doc[:beneficiaries][:ages].map { |h| h["label"] }
      #@grant.age_group_ids << AgeGroup.where(label: age_group_labels).pluck(:id)
#
      #save(@grant, grant_values)
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
