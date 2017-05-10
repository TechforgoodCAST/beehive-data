# usage:    bundle exec rake update:areas
# optional: SAVE=true
# optional: state = import,review # comma separated list of states to include

namespace :update do
  desc 'Update each grant with details of countries and districts'
  task areas: :environment do

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

    counts = {saved: 0, invalid: 0, unchanged: 0}

    @countries = Country.all.to_a
    @districts = District.all.to_a
    gb_id = Country.find_by(alpha2: 'GB')[:id]
    states = (ENV['state'] || "import,review").split(",")

    Grant.includes(:countries, :districts).where(state: states).find_each do |grant|

      grant.get_countries(@countries, @districts)
      counts = save(grant, counts)

      grant.state = 'approved'
      grant.save if ENV['SAVE']
    end

    puts "\n"
    puts "#{counts[:saved]} grants updated with beneficiary details"
    puts "#{counts[:invalid]} grants could not be updated (invalid)"
    puts "#{counts[:unchanged]} grants unchanged"

    if @errors.count > 0
      puts "\nErrors\n------"
      puts @errors
    end
    puts "\n"

  end
end
