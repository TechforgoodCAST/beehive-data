# usage:    bundle exec rake update:charity
# optional: CHARITY_BASE_DB_URL=0.tcp.ngrok.io:12345
# optional: SAVE=true

namespace :update do
  desc 'Update organisation data to include charity'
  task charity: :environment do
    require 'mongo'

    # Set up MongoDB
    Mongo::Logger.logger.level = ::Logger::FATAL
    charitybase = Mongo::Client.new(
      [ ENV['CHARITY_BASE_DB_URL'] || '127.0.0.1:27017' ],
      database: 'charity-base'
    )

    @errors = []
    def save(obj, counts)
      if obj.valid?
        if obj.changed?
          print '.'
          counts[:saved]+=1
          obj.save if ENV['SAVE']
        else
          print '_'
          counts[:unchanged]+=1
        end
      else
        print '*'
        counts[:invalid]+=1
        @errors << "#{obj.send("#{obj.class.name.downcase}_identifier")}: #{obj.errors.full_messages}"
      end
      return counts
    end

    # get charity commission lookups
    @ccareas = {}
    CSV.foreach(Rails.root.join('lib', 'assets', 'csv', 'cc-aoo-gss-iso.csv'), headers: true) do |row|
      @ccareas["#{row["aootype"]}#{row["aookey"]}"] = row.to_hash
    end
    # get district lookups
    @countries = Country.all.to_a
    @districts = District.all.to_a
    gb_id = Country.find_by(alpha2: 'GB')[:id]

    # Start updating charity data

    # First check for any missing charity numbers
    # @TODO: currently doesn't save some records due to duplicate charity numbers - find a way to merge records.
    counts = {saved: 0, invalid: 0, unchanged: 0}
    Organisation.where("(organisation_identifier LIKE 'GB-CHC-%' OR organisation_identifier LIKE 'GB-SC-%') AND charity_number IS NULL").find_each do |org|
      org[:charity_number] = org.parseCharityNumber(org[:organisation_identifier])
      org.org_type = 0 # change org type to trigger the "set_org_type" function
      counts = save(org, counts)
    end
    puts "\n"
    puts "#{counts[:saved]} charity numbers added from organisation_identifier"
    puts "#{counts[:invalid]} charity numbers not added from organisation_identifier (charity number already exists)"
    puts "#{counts[:unchanged]} charity numbers unchanged"

    # Then go through all the organisations with charity numbers (and amend their grants)
    counts = {org: {saved: 0, invalid: 0, unchanged: 0}, grant: {saved: 0, invalid: 0, unchanged: 0}}
    Organisation.import.includes(grants_as_recipient: :beneficiaries).where("charity_number IS NOT NULL AND scraped_at IS NULL").find_each do |org|

      # get the charity information
      charity = org.get_charitybase(charitybase, @countries, @districts, @ccareas, gb_id)
      org.scraped_at = DateTime.now
      org.state = 'approved'

      unless org.valid?
        if org.errors[:company_number]
          org.restore_company_number!
        end
      end

      counts[:org] = save(org, counts[:org])

      org.grants_as_recipient.import.each do |grant|
        counts[:grant] = save(grant, counts[:grant])
      end

    end
    puts "\n"
    puts "#{counts[:org][:saved]} organisations updated with charity details"
    puts "#{counts[:org][:invalid]} organisations could not be updated (invalid)"
    puts "#{counts[:org][:unchanged]} organisations unchanged"
    puts "\n"
    puts "#{counts[:grant][:saved]} grants updated with charity details"
    puts "#{counts[:grant][:invalid]} grants could not be updated (invalid)"
    puts "#{counts[:grant][:unchanged]} grants unchanged"
    if @errors.count > 0
      puts "\nErrors\n------"
      puts @errors
    end
    puts "\n"

  end
end
