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
      invalid_grants:        0,
      skipped_year:          0,
      skipped_individual:    0,
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

    # Regexes
    BEN_REGEXES = {
      :crime => /\b(crim(inal|e)|justice|judicial|offenders?|custody|anti-social behaviour|prison(ers?)?|law centre|victim|murder|rape|theft|fraud)\b/i, # possible confusion with "social justice" and "restorative justice",
      :relationship => /\b(relationship|marriage|family breakdown|mediation|counselling|conflict resolution)\b/i, # relationship a bit general
      :disabilities => /\b(disabled|disabilit(ies|y)|blind(ness)?|deaf(ness)?|(hearing|sight) loss|amputee|wheel ?\-?chair|accessib(ility|le)|handicap(ped)?|less abled|sign language|impairment|visual(ly)? ?\-?impair(ment|ed))\b/i,
      :religion => /\b(christ(ian)?|muslim|jew(ish)|mosque|synagogue|church|buddhis(t|m)|sikh)\b/i, # bit wide, need to exclude, eg church halls
      :disasters => /\b(flood(s|ing)?|disasters?|rescue|survivors?|tsunami|storms?|hurricane|aftermath)\b/i, # need a wider range "survivors" has DV use too, rescue used a lot for animals
      :education => /\b(schools?|pupils?|students?|school\-?age|teach(ers?|ing)|college|a ?\-?levels?|g\.?c\.?s\.?e\.?s?|key stage (1|2|3|one|two|three)|mentoring|educational|school(child|boy|girl)(ren|s)?|classroom)\b/i, # need to exclude pre-school? schools are a venue for lots of activities
      :unemployed => /\b((un)?-?employ(ed|ment)|job-?seekers?|benefit claimants?|claim benefits|jobless|out of work)\b/i,
      :ethnic => /\b(b\.?a?m\.?e\.?|black|ethnic|racial|roma)\b/i, # black may be too generic?
      :water => /\b(water|sanitation|toilets?|sewage|hygien(e|ic)|wastewater)\b/i, # need to exclude water sports
      :food => /\b(food|hunger|feed|local produce|food\-?bank|fruits?|vegetables?|cook(ery|ing)|famines?|(mal)?nutrition(ist)?|meat)\b/i,
      :housing => /\b(housing|homeless(ness)?|tenants?|rough ?\-?sleep(ing|ers?)|runaways?|residents?|household|shelter)\b/i, # housing is a verb, and is generic
      :animals => /\b(animals?|pets?|dogs?|cats?|horses?|wildlife|fauna|farm-animal|livestock|marine|habitat|birds?)\b/i,
      :buildings => /\b((community|new|existing) building|built environment|architecture|refurbish(ing|ment)?|repairs?|restoration|(community|village) hall|Preservation Trust|Building works)\b/i, # building and heritage both a bit too wide
      :mental => /\b(mental ?\-?(health|illness(es)?|diseases?|disorders?)|depressian|schizophrenia|bi\-?polar|psychiatry|psychiatric|eating ?-?disorders?|Self ?\-?help)\b/i, # mental disease could cover dementia/learning disabilities
      :orientation => /\b(l\.?g\.?b\.?t?\.?q?\.?|lesbian|gay|bi\-?sexual|sexuality|sexual orientation|trans\-?(sexual|gender)?|homo\-?sexual|queer|cisgender|intersex)\b/i, # rainbow - but children too
      :environment => /\b(environment(al)?|climat(e|ic)|global warming|carbon|energy efficien(t|cy)|ecosystem|nature|green spaces?|bio\-?diversity|sustainab(ility|le)|countryside|garden|pond|parks?|eco\-?audit|footpaths?|wilderness|greenhouse gas|ecolog(y|ical))\b/i, # environment a bti broad: learning environment, peaceful environment, etc
      :physical => /\b(physical health|cancer|disease|illness|Down\'?s Syndrome|get fit|fitness|sport(ing|s)?|physiotherapy|Multiple Sclerosis|stroke|diabetes|Healthy Living|health ?care|blood pressure|virus|infection)\b/i, # exclude mental? often says "physical and mental health"
      :organisation => /\b((this|our) organisation|core (costs|funding))\b/i, # not sure about this one!
      :organisations => /\b(charities|local groups|community groups|social enterprises|Council for Voluntary Service|VCS)\b/i,
      :poverty => /\b(poverty|deprivation|isolation|disadvantaged)\b/i, # "poor" is too generic, used as an adjective
      :refugees => /\b(asylum ?-?seekers?|refugees?|migrants?|displaced persons?)\b/i, # sanctuary?
      :services => /\b(armed forces|army|navy|air force|marines|armed services|(ex\-)?servicem(e|a)n\'?s?|veterans?|british legion|regiment(al)?|military|sailors?|soldiers?)\b/i,
      :care => /\b(care ?\-?leavers?|leaving care|looked ?\-?after ?\-?(children)?|carers?|leave care)\b/i, # definition of care here?
      :exploitation => /\b((sex)? ?\-?traffic(k?ing)?|exploitation|forced labour|sex ?\-?workers?|prostitut(es?|ion))\b/i,

      # the following are not in the original list
      :abuse => /\b((domestic|sexual) (violence|abuse)|violence against women|honou?r killings?|child abuse)\b/i,
      :addiction => /\b(addict(ion)?|(alcohol|drug) abuse|alcohol(ism)?|drugs?|narcotics?|abstinence)\b/i,
      :learningdisabilities => /\b((learning|intellectual) (difficult|disabilit|disorder)(ies|y)?)\b/i,

      # not really beneficiaries
      #:arts-culture => /\b(arts?|theatre|music(al)?|museums?|galler(y|ies))\b/i,
      #:sport-recreation => /\b(cricket|rugby|football|Tennis|swimming)\b/i,
      #:research => /\b()\b/i,
    }

    GENDER_REGEXES = {
      # the following identify genders
      :men => /\b(m(e|a)n|boys?|fathers?|males?|lads?)\b/i,
      :women => /\b(wom(e|a)n|girls?|lad(y|ies)|mothers?|females?|lesbians?)\b/i,
      :transgender => /\b(trans\-?(sexual|gender)?)\b/i,
    }

    AGE_REGEXES = {
        # the following identify ages or life stages
        :baby => {:regex => /\b(bab(ies|y)|neo\-?nat(al|e)|childbirth|infants?|toddlers?|preschoolers?|newborn)\b/i, :age_from => 0, :age_to => 3},
        :children => {:regex => /\b(child(ren)|junior|kids)\b/i, :age_from => 4, :age_to => 11},
        :youngpeople => {:regex => /\b(young ?\-?people|youth|teen\-?agers?|adolescen(ce|ts)|juveniles?|puberty)\b/i, :age_from => 12, :age_to => 25},
        :adults => {:regex => /\b(adult)\b/i, :age_from => 25, :age_to => 65},
        :elderly => {:regex => /\b(elderly|old(er)? ?\-?people|pensioners?|senior citizens?|(octo|nona)genarian|((second|2nd|1st|first) world war|WW(II|2)) veteran)\b/i, :age_from => 65, :age_to => 100},
        #:family => {:label => /\b(famil(y|ies))/i, :age_from => 0, :age_to => 3},
    }

    # the selected age groups with their age ranges
    AGE_CATEGORIES = [
        {:label => "All ages", :age_from => 0, :age_to => 150},
        {:label => "Infants (0-3 years)", :age_from => 0, :age_to => 3},
        {:label => "Children (4-11 years)", :age_from => 4, :age_to => 11},
        {:label => "Adolescents (12-19 years)", :age_from => 12, :age_to => 19},
        {:label => "Young adults (20-35 years)", :age_from => 20, :age_to => 35},
        {:label => "Adults (36-50 years)", :age_from => 36, :age_to => 50},
        {:label => "Mature adults (51-80 years)", :age_from => 51, :age_to => 79},
        {:label => "Older adults (80+)", :age_from => 80, :age_to => 150}
    ]

    # fund names to replace when going through the data
    # for each funder you can either have
    # - a string (replace all with this),
    # - a dict (perform name replacement)
    # @todo - export to a separate file for easier editing
    SWAP_FUNDS = {
        "Oxfordshire Community Foundation" => "",
        "BBC Children in Need" => {
            "zPositive Destinations" => "Positive Destinations",
            "zFun and Friendship" => "Fun and Friendship"
        },
        "Lloyds Bank Foundation for England and Wales" => {
            "ZMSW - Community" => "Community",
            "XA7 - Criminal Justice" => "Criminal Justice",
            "XA1 - Community" => "Community",
            "XA2 - Community" => "Community",
            "XA12 - Community" => "Community",
            "ZHNWL - Young Offenders" => "Young Offenders",
            "Enable South" => "Enable",
            "XA10 - Criminal Justice" => "Criminal Justice",
            "ZSCSWL - Community" => "Community",
            "ZKSEL - Young Offenders" => "Young Offenders",
            "XA0 - Older People Programme" => "Older People Programme",
            "XA4 - Criminal Justice" => "Criminal Justice",
            "ZLNM - Community" => "Community",
            "ZNWS - Community" => "Community",
            "XA6 - Community" => "Community",
            "XA7 - Community" => "Community",
            "XA10 - Community" => "Community",
            "ZHNWL - Community" => "Community",
            "ZKSEL - Community" => "Community",
            "XA9 - Criminal Justice" => "Criminal Justice",
            "ZSWC - Community" => "Community",
            "XA2 - Criminal Justice" => "Criminal Justice",
            "XA11 - Community" => "Community",
            "ZENEL - Community" => "Community",
            "ZENEL - Young Offenders" => "Young Offenders",
            "XA11 - Criminal Justice" => "Criminal Justice",
            "XA5 - Community" => "Community",
            "ZNEC - Community" => "Community",
            "ZLarge Grants Programme" => "Large Grants Programme",
            "ZNWM - Community" => "Community",
            "Enable North" => "Enable",
            "ZLNS - Community" => "Community",
            "ZWMS - Community" => "Community",
            "XA9 - Community" => "Community",
            "ZEST - Community" => "Community",
            "ZYKS - Community" => "Community",
            "ZDCL - Community" => "Community",
            "ZCSM - Community" => "Community",
            "XA3 - Community" => "Community",
            "XA6 - Criminal Justice" => "Criminal Justice",
            "Invest South" => "Invest",
            "XA8 - Community" => "Community",
            "XA4 - Community" => "Community",
            "Invest North" => "Invest"
        },
        "Virgin Money Foundation" => {
            "North East Fund 2016" => "North East Fund",
            "North East Fund 2015" => "North East Fund"
        },
        "LandAid Charitable Trust" => {
            "Empty Properties Grants round 2015/16" => "Empty Properties Grants",
            "Grants 2014/15" => "Grants",
            "Open Grants round 2014/15" => "Open Grants",
            "Project Sponsorship 2014/15" => "Project Sponsorship",
            "Open Grants round 2013/14" => "Open Grants",
            "Joint funding 2013/14" => "Joint funding",
            "Open Grants round 2012/13" => "Open Grants",
            "Joint Funding 2014/15" => "Joint funding",
            "Project Sponsorship 2015/16" => "Project Sponsorship",
            "Open Grants round 2015/16" => "Open Grants",
        },
    }

    # charity utilities
    # TODO move to separate file?
    def get_charity_and_company( charno, compno, cdb)
      charity = nil
      company = nil

      # first check if charty or company exists
      charity = get_charity( charno, cdb )
      company = get_company( compno, cdb )

      # if the charity exists but company doesn't check for company based on charity
      if(charity && company.nil?)
        company = get_company_from_charity(charity, cdb)
      end

      # if the company exists but the charity doesn't check for charity based on company
      if(charity.nil? && company)
        charity = get_charity_from_company(company, cdb)
      end

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
      regno.sub!('GB-SC-', '')
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
        return cdb[:charities].find({"charityNumber" => { :$in => [charno, charno.to_s]}, "subNumber" => 0 } ).limit(1).first
      end
    end

    def get_company( compno, cdb )
      # TODO: proper company parsing
      compno = parseCharityNumber(compno)
      if compno
        return {"companyNumber" => compno}
      end
    end

    def get_charity_from_company( company, cdb )
      companyNumber = parseCharityNumber(company[:companyNumber])
      if companyNumber
        return cdb[:charities].find({"mainCharity.companyNumber" => companyNumber}).first
      end
    end

    def get_company_from_charity( charity, cdb )
      return get_company(charity.fetch("mainCharity", {}).fetch("companyNumber", nil), cdb)
    end


    def get_char_financial(char = nil, time_from=nil)
      """
      Financial information

      Retrieved either based on the latest available data (if time_from is
      None) or based on a date given.
      """
      financial = {
          "income": -1,
          "spending": -1,
          "financial_fye": nil,
          "employees": -1,
          "volunteers": -1,
          "people_fye": nil
      }
      if char.nil?
        return financial
      end
      grant_date = time_from
      if time_from.nil?
        time_from = Date.today
      end

      # income and spending
      fin = char.fetch("financial", []).find_all{ |i| i["income"] && i["spending"]}
      fin = fin.sort { |a, b| b["fyEnd"] <=> a["fyEnd"] }
      use_fin = fin.find{|i| (time_from <= i["fyEnd"] && time_from >= i["fyStart"]) } || fin.last

      income_bands = [10_000, 100_000, 1_000_000, 10_000_000, 10_000_000_000]

      if use_fin
        financial[:financial_fye] = use_fin["fyEnd"]
        financial[:income] = income_bands.find_index{ |f| f >= use_fin["income"].to_i }
        financial[:spending] = income_bands.find_index{ |f| f >= use_fin["spending"].to_i }
      end

      # volunteers and employees
      partb = char.fetch("partB", []).sort{ |a, b| b["fyEnd"] <=> a["fyEnd"] }
      use_partb = partb.find{|i| (time_from <= i["fyEnd"] && time_from >= i["fyStart"])} || partb.last

      employee_bands = [0, 5, 25, 50, 100, 250, 500, 1_000_000]

      if use_partb
        financial[:people_fye] = use_partb["fyEnd"]
        financial[:employees] = employee_bands.find_index{ |f| f >= use_partb.fetch("people", {}).fetch("employees", 0).to_i }
        financial[:volunteers] = employee_bands.find_index{ |f| f >= use_partb.fetch("people", {}).fetch("volunteers", 0).to_i }
      end

      return financial
    end

    def get_organisation_type( recipient )
      # ["An individual", -1],
      # ["An unregistered organisation OR project", 0],
      # ["A registered charity", 1],
      # ["A registered company", 2],
      # ["A registered charity & company", 3],
      # ["Another type of organisation", 4]
      org_type = nil
      name = recipient.fetch(:name, "")
      charity = recipient.fetch(:charity, nil) or parseCharityNumber(recipient.fetch(:charityNumber, nil))
      company = recipient.fetch(:company, nil) or parseCharityNumber(recipient.fetch(:companyNumber, nil))
      if charity
        if company
          org_type = 3
        else
          org_type = 1
        end
      elsif company
        org_type = 2
      elsif name=="This is a programme for individual veterans as opposed to organisaitons"
        org_type = -1
      elsif /\b(school|college|university|council|academy|borough)\b/i.match(name)
        org_type = 4
      else
        org_type = 0
      end

      return org_type
    end

    def get_operating_for(charity = nil, grant_date = nil)
      if charity.nil?
        return -1
      end
      if grant_date.nil?
        grant_date = Date.today
      end

      char_reg = charity.fetch("registration", [])[0].fetch("regDate", nil)
      if char_reg.nil?
        return -1
      end

      age = ((grant_date - char_reg.to_date).to_f / 365)
      if age <= 1
        return 1
      elsif age > 1 && age <= 3
        return 2
      elsif age > 3
        return 3
      end
    end

    # beneficiary utilities
    def get_charity_beneficiaries(char)
      # Get a list of beneficiaries based on the charity's beneficiaries
      beneficiaries = []

      # convert charity commission classification categories to beehive ones
      cc_to_beehive = {
          105 => "poverty",
          108 => "religious",
          111 => "animals",
          203 => "disabilities",
          204 => "ethnic",
          205 => "organisations",
          207 => "public",
      }

      # convert OSCR classification categories to beehive ones
      oscr_to_beehive = {
          "No specific group, or for the benefit of the community" => "public",
          "People with disabilities or health problems" => "disabilities",
          "The advancement of religion" => "religious",
          "People of a particular ethnic or racial origin" => "ethnic",
          "The advancement of animal welfare" => "animals",
          "The advancement of environmental protection or improvement" => "environment",
          "Other charities / voluntary bodies" => "organisations",
          "The prevention or relief of poverty" => "poverty",
      }

      if char.nil?
          return beneficiaries
      end

      # Charity Commission beneficiaries
      beneficiaries.concat (char[:class] & cc_to_beehive.keys).map{|c| cc_to_beehive[c] }

      # OSCR beneficiaries
      char.fetch(:beta, {}).each do |i, v|
        beneficiaries.concat (v & oscr_to_beehive.keys).map{ |c| oscr_to_beehive[c] }
      end

      return beneficiaries.uniq

    end

    # start

    # get JSON file
    file = File.read(ENV["GRANTNAV_FILE"] || "grantnav.json")
    grantnav = JSON.parse(file, {:symbolize_names => true})
    puts grantnav[:grants].count
    if (ENV["SAMPLE"].to_i || 0) > 0
      puts "Sampling #{ENV["SAMPLE"].to_i} grants"
      collection = grantnav[:grants].sample(ENV["SAMPLE"].to_i).shuffle
    else
      collection = grantnav[:grants]
    end

    Mongo::Logger.logger.level = ::Logger::FATAL
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

        # use charity numbers or company numbers from org id
        if (r[:id][0..7]=="GB-CHC-" || r[:id][0..6]=="GB-SC-")
          r[:charityNumber] = r[:charityNumber] || r[:id]
        end
        if (r[:id][0..7]=="GB-COH-")
          r[:companyNumber] = r[:companyNumber] || r[:id]
        end

        char_comp = get_charity_and_company( r[:charityNumber], r[:companyNumber], charitybase )
        r[:charity] = char_comp[0]
        r[:company] = char_comp[1]

        # get charity beneficiaries
        r[:beneficiaries] = get_charity_beneficiaries(r[:charity])

        # get organisation type
        r[:org_type] = get_organisation_type(r)
        if r[:org_type]==-1
          r[:name] = nil
        end

        # get charity financials
        r[:financial] = get_char_financial( r[:charity], doc[:awardDate] )

        # work out the time operating_for
        r[:operating_for] = get_operating_for(r[:charity], doc[:awardDate])

        # sort out postcode
        if r[:postalCode].to_s.strip.empty?
          r[:postalCode] = "Unknown"
          if r[:charity]
            r[:postalCode] = r[:charity].fetch("contact", {}).fetch("postcode", "Unknown")
            if r[:postalCode].empty?
              r[:postalCode] = "Unknown"
            end
          end
        end

        # sort out website
        if r[:url].to_s.strip.empty?
          r[:url] = nil
          if r[:charity]
            r[:url] = r[:charity].fetch("mainCharity", {}).fetch("website", nil)
          end
        end

        if r[:url] !~ URI::regexp(%w(http https))
          if r[:url].present? and "http://" + r[:url] =~ URI::regexp(%w(http https))
            r[:url] = "http://" + r[:url]
          else
            r[:url] = nil
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
        country:                 Country.find_by(alpha2: doc[:recipientOrganization][0].fetch(:country, 'GB')),
        website:                 doc[:recipientOrganization][0][:url].presence,
        org_type:                doc[:recipientOrganization][0][:org_type],
        multi_national:          false, # TODO find actual multi_national value
      }

      save(@recipient, recipient_values)

      @grant = Grant.where(grant_identifier: doc[:id])
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
      }

      desc = "#{doc[:title]} #{doc[:description]}"

      genders = GENDER_REGEXES.select{|gender, reg| desc =~ reg }.keys.uniq
      if genders.count==1
        grant_values[:gender] = genders[0]
      end

      ben_names = BEN_REGEXES.select {|ben, reg| desc =~ reg }.keys
      ben_names.concat doc[:recipientOrganization][0][:beneficiaries]
      @grant.beneficiary_ids << Beneficiary.where(sort: ben_names.uniq).pluck(:id)

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

      @grant.age_group_ids << AgeGroup.where(label: age_group_labels).pluck(:id)

      save(@grant, grant_values)

    end

    puts "\n\n"
    puts "Skipped: #{@counters[:skipped_year]} grants due to the year"
    puts "Skipped: #{@counters[:skipped_individual]} grants as to individuals"
    log(@recipient)
    log(@grant)
    if @errors.count > 0
      puts "\nErrors\n------"
      puts @errors
    end
    puts "\n"
  end
end
