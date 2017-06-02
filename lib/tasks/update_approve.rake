# usage:    bundle exec rake update:approve
# optional: SAVE=true

namespace :update do
  desc 'Attempt to mark any unapproved grants as approved'
  task approve: :environment do


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

    states = (ENV['state'] || "import,review").split(",")
    Grant.where(state: states).find_each do |grant|
      grant.state = 'approved'
      save(grant, counts)
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
