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

    # Start updating charity data

    # First check for any missing charity numbers
    # @TODO: currently doesn't save some records due to duplicate charity numbers - find a way to merge records.
    # counts = {saved: 0, invalid: 0}
    # Organisation.where("(organisation_identifier LIKE 'GB-CHC-%' OR organisation_identifier LIKE 'GB-SC-%') AND charity_number IS NULL").find_each do |org|
    #   org[:charity_number] = parseCharityNumber(org[:organisation_identifier])
    #   org.org_type = 0 # change org type to trigger the "set_org_type" function
    #   org.save ? counts[:saved]+=1 : counts[:invalid]+=1
    # end
    # puts "#{counts[:saved]} charity numbers added from organisation_identifier"
    # puts "#{counts[:invalid]} charity numbers not added from organisation_identifier (charity number already exists)"

    # Then go through all the organisations with charity numbers (and amend their grants)
    Organisation.includes(grants_as_recipient: :beneficiaries).where("charity_number IS NOT NULL").limit(10).find_each do |org|

      # get the charity information
      charity = org.get_charitybase(charitybase)

      unless org.valid?
        if org.errors[:company_number]
          org.restore_company_number!
        end
      end

      puts "<Organisation #{org.organisation_identifier}>", org.changes
      #org.save!

    end

  end
end
