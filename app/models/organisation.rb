class Organisation < ActiveRecord::Base

  scope :newest,    -> { order(updated_at: :desc) }
  scope :funder,    -> { where(publisher: true) }
  scope :recipient, -> { where(publisher: false) }
  scope :import,    -> { where(state: 'import') }
  scope :review,    -> { where(state: 'review') }
  scope :approved,  -> { where(state: 'approved') }

  ORG_TYPE = [
    ['An individual', -1],
    ['An unregistered organisation OR project', 0],
    ['A registered charity', 1],
    ['A registered company', 2],
    ['A registered charity & company', 3],
    ['Another type of organisation', 4]
  ]

  belongs_to :country
  has_many :grants_as_funder, class_name: 'Grant', foreign_key: 'funder_id'
  has_many :grants_as_recipient, class_name: 'Grant', foreign_key: 'recipient_id'
  has_many :moderators, as: :approvable
  has_many :users, through: :moderators

  validates :organisation_identifier, :slug, uniqueness: true, presence: true
  validates :charity_number, uniqueness: true, if: :charity_number?
  validates :company_number, uniqueness: true, if: :company_number?
  validates :organisation_number, uniqueness: true, if: :organisation_number?
  validates :name, :country_id, :org_type, :state, presence: true

  validates :publisher, :multi_national, :registered,
              inclusion: { in: [true, false] }, if: 'review? || approved?'
  validates :postal_code, presence: true, if: 'review? || approved?'
  validates :website, format: { with: URI::regexp(%w(http https)),
              message: 'enter a valid website address e.g. http://www.example.com'},
              if: :website?

  before_validation :set_slug, if: -> (o) { o.name_changed? }
  before_validation :set_org_type, :set_registered, :clear_numbers_for_unknown_orgs

  include Workflow
  workflow_column :state
  workflow do
    state :import do
      event :next_step, transitions_to: :review
    end
    state :review do
      event :next_step, transitions_to: :approved
    end
    state :approved
  end

  def recent_grants_as_funder
    most_recent_grant = self.grants_as_funder.order(:award_date).last
    if most_recent_grant
      earliest_award_date = most_recent_grant.award_date - 365
    else
      earliest_award_date = 365.days.ago
    end
    self.grants_as_funder
      .where(state: 'approved')
      .where('award_date >= ?', earliest_award_date)
  end

  def to_param
    self.slug
  end

  def set_slug
    self.slug = generate_slug
  end

  def scrape_org
    if self.company_number && !self.charity_number
      find_companies_house
    else
      find_charity_commission
    end
  end

  def use_scrape_data
    if self.scrape.keys.count > 0
      self.attributes = self.scrape['data'].except('regions', 'score')
    end
  end

  def charity_commission_url
    "http://beta.charitycommission.gov.uk/charity-details/?regid=#{CGI.escape(charity_number)}&subid=0"
  end

  def companies_house_url(company_number=self.company_number)
    "https://beta.companieshouse.gov.uk/company/#{CGI.escape(company_number)}"
  end

  private

    def parse_to_array(response)
      if response.count > 0
        return response.text.gsub(/\t|\r/, '').split("\n").reject(&:empty?)
      else
        return []
      end
    end

    def financials_multiplier(scrape)
      if scrape.present?
        string = scrape.text.sub('£', '')
        case string.last
        when 'K'
          string = string.sub('K', '')
          return string.to_f * 1000
        when 'M'
          string = string.sub('M', '')
          return string.to_f * 1000000
        end
      end
    end

    def find_charity_commission
      require 'open-uri'
      response = Nokogiri::HTML(open(charity_commission_url)) rescue nil

      if response
        data = {}
        root_id = '#ContentPlaceHolderDefault_cp_content_ctl00_CharityDetails_4_TabContainer1_tp'

        if name = response.at_css('h1')
          data[:name] = name.text
        end

        if postal_code = response.at_css(root_id + 'Overview_plContact .detail-50+ .detail-50 .detail-panel-wrap')
          data[:postal_code] = postal_code.text.split(',').last.strip
        end

        if website = response.at_css(root_id + 'Overview_plContact h3+ a')
          data[:website] = website.text
        end

        if regions = response.css(root_id + 'Operations_plList li')
          data[:regions] = parse_to_array(regions)
          data[:multi_national] = (data[:regions] & CharityCommissionConstants::COUNTIRES).count > 1 ? true : false
        end

        if company_number = response.at_css(root_id + 'Overview_plCompanyNumber')
          data[:company_number] = company_number.text.sub(/Company no. 0?/, '0').strip
          self.org_type = 3
        end

        data[:score] = data.keys.count

        background = {}

        background[:income] = financials_multiplier(response.at_css('.detail-33:nth-child(1) .big-money'))
        background[:spending] = financials_multiplier(response.at_css('.detail-33:nth-child(2) .big-money'))

        def parse_people_numbers(response, nth_child)
          if element = response.at_css("#tpPeople li:nth-child(#{nth_child}) .mid-money")
            return element.text.to_i
          end
        end

        background[:trustees]   = parse_people_numbers(response, 1)
        background[:employees]  = parse_people_numbers(response, 2)
        background[:volunteers] = parse_people_numbers(response, 3)

        if what = response.at_css('#plWhatWhoHow .detail-50:nth-child(1) .detail-panel-wrap')
          background[:what] = parse_to_array(what)
        end
        if who = response.at_css('#plWhatWhoHow .detail-50+ .detail-50 .detail-panel-wrap')
          background[:who] = parse_to_array(who)
        end
        if how = response.at_css('.detail-100 .detail-panel-wrap')
          background[:how] = parse_to_array(how)
        end

        if data[:company_number]
          background = background.merge(find_companies_house(data[:company_number])[:background])
        end

        return { data: data, background: background }
      end
    end

    def find_companies_house(company_number=self.company_number)
      require 'open-uri'
      response = Nokogiri::HTML(open(companies_house_url(company_number))) rescue nil

      if response
        companies_house_data = {}
        companies_house_data[:company_type] = response.at_css('#company-type')
                                                .text.gsub(/\n/, '').strip
        companies_house_data[:incorporated_date] = response.at_css('#company-creation-date')
                                                     .text.gsub(/\n/, '').strip.to_date if
                                                     response.at_css('#company-creation-date')
        companies_house_data[:company_status] = response.at_css('#company-status')
                                                .text.gsub(/\n/, '').strip
        sic_array = []
        10.times do |i|
          sic_array << response.at_css("#sic#{i}").text.strip if response.at_css("#sic#{i}").present?
        end
        companies_house_data[:sic_code] = sic_array

        return { background: companies_house_data }
      else
        return { background: {} }
      end
    end

    def generate_slug(n=1)
      return nil unless self.name
      candidate = self.name.parameterize
      candidate += "-#{n}" if n > 1
      return candidate unless Organisation.find_by_slug(candidate)
      generate_slug(n+1)
    end

    def set_org_type
      unless self.org_type.to_i > 3 || self.org_type.to_i < 0
        if self.charity_number? && self.company_number?
          self.org_type = 3
        elsif self.charity_number? && !self.company_number?
          self.org_type = 1
        elsif !self.charity_number? && self.company_number?
          self.org_type = 2
        elsif self.organisation_number? && (!self.charity_number? && !self.company_number?)
          self.org_type = 4
        else
          self.org_type = 0
        end
      end
    end

    def set_registered
      unless self.org_type.to_i > 3 || self.org_type.to_i < 0
        self.org_type > 0 ? self.registered = true : self.registered = false
      end
      return true
    end

    def clear_numbers_for_unknown_orgs
      if self.org_type.to_i > 3 || self.org_type.to_i < 0
        self.charity_number = nil
        self.company_number = nil
        self.organisation_number = nil
      end
    end

end
