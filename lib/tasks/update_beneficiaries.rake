# usage:    bundle exec rake update:beneficiaries
# optional: SAVE=true
# optional: state = import,review # comma separated list of states to include
# optional: FUND='fund-slug' # to limit to a particular fund

namespace :update do
  desc 'Update each grant with details of beneficiaries'
  task beneficiaries: :environment do

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
    states = (ENV['state'] || "import").split(",")
    where_clause = {state: states}
    if ENV['FUND']
      where_clause[:fund_slug] = ENV['FUND']
    end

    Grant.where(where_clause).includes(:recipient, :beneficiaries).find_each do |grant|

      grant.gender_regex()
      grant.ben_regex()
      grant.age_regex()
      counts = save(grant, counts)
      if grant.beneficiaries.count > 0
        grant.state = 'review'
        grant.save if ENV['SAVE']
      end
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
