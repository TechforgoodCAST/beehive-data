class Grant < ActiveRecord::Base

  scope :recent, -> (fund) {
    most_recent_grant = where(state: 'approved', fund_slug: fund).order(:award_date).last
    if most_recent_grant
      earliest_award_date = most_recent_grant.award_date - 365
    else
      earliest_award_date = 365.days.ago
    end
    where(state: 'approved', fund_slug: fund)
      .where('award_date >= ?', earliest_award_date)
  }

  scope :newest,   -> { order(updated_at: :desc) }
  scope :import,   -> { where(state: 'import') }
  scope :review,   -> { where(state: 'review') }
  scope :approved, -> { where(state: 'approved') }
  scope :with_approved_recipients, -> {
    find_by_sql("
      SELECT grants.* FROM grants
      INNER JOIN organisations ON organisations.id = grants.recipient_id
      WHERE (grants.state = 'import' AND organisations.state = 'approved')
      ORDER BY updated_at DESC
    ") }

  VALID_YEARS = (Date.today.year-10..Date.today.year).to_a
  GENDERS = ['All genders', 'Female', 'Male', 'Transgender', 'Other']
  OPERATING_FOR = [
    ['Yet to start', 0],
    ['Less than 12 months', 1],
    ['Less than 3 years', 2],
    ['4 years or more', 3],
    ['Unknown', -1]
  ]
  INCOME = [
    ['Less than £10k', 0],
    ['£10k - £100k', 1],
    ['£100k - £1m', 2],
    ['£1m - £10m', 3],
    ['£10m+', 4],
    ['Unknown', -1]
  ]
  EMPLOYEES = [
    ['None', 0],
    ['1 - 5', 1],
    ['6 - 25', 2],
    ['26 - 50', 3],
    ['51 - 100', 4],
    ['101 - 250', 5],
    ['251 - 500', 6],
    ['500+', 7],
    ['Unknown', -1]
  ]
  GEOGRAPHIC_SCALE = [
    ['One or more local areas', 0],
    ['One or more regions', 1],
    ['An entire country', 2],
    ['Across many countries', 3]
  ]
  FUNDING_TYPE = [
    ['Capital funding', 0],
    ['Revenue funding - project costs', 1],
    ['Revenue funding - running costs', 2],
    ['Revenue funding - unrestricted (both project and running costs)', 3],
    ['Other', 4]
  ]

  belongs_to :funder, class_name: 'Organisation'
  belongs_to :recipient, class_name: 'Organisation'

  has_many :moderators, as: :approvable
  has_many :users, through: :moderators

  has_many :locations, dependent: :destroy
  has_many :countries, through: :locations
  has_many :regions, dependent: :destroy
  has_many :districts, through: :regions

  has_many :ages, dependent: :destroy
  has_many :age_groups, through: :ages
  has_many :stakeholders, dependent: :destroy
  has_many :beneficiaries, through: :stakeholders

  validates :grant_identifier, uniqueness: true
  validates :grant_identifier, :funder, :recipient, :state, :award_year,
            :fund_slug, :title, :description, :currency, :funding_programme,
            :amount_awarded, :award_date,
              presence: true
  validates :award_year, inclusion: { in: VALID_YEARS }
  validates :duration_funded_months, presence: true, if: 'planned_start_date? && planned_end_date?'
  validate :planned_start_date_before_planned_end_date

  validates :age_groups,
              presence: true, if: 'affect_people && (review? || approved?)'
  validate  :beneficiary_groups, if: 'review? || approved?'
  validates :countries,
              presence: true, if: 'review? || approved?'
  validates :districts, presence: true,
              unless: Proc.new { self.geographic_scale > 1 if self.geographic_scale },
              if: 'review? || approved?'
  validate  :ensure_districts_for_country
  validates :type_of_funding, inclusion: { in: 0..4 },
              if: 'type_of_funding && (review? || approved?)'
  validates :operating_for, inclusion: { in: -1..3 },
              if: 'review? || approved?'
  validates :income, inclusion: { in: -1..4 },
              if: 'review? || approved?'
  validates :employees, :volunteers, inclusion: { in: -1..7 },
              if: 'review? || approved?'
  validates :affect_people, :affect_other,  inclusion: { in: [true, false] },
              if: 'review? || approved?'
  validates :affect_people, presence: { message: 'cannot be false if Affect other is false' }, unless: 'affect_other?', if: 'review? || approved?'
  validates :affect_other, presence: { message: 'cannot be false if Affect people is false' }, unless: 'affect_people?', if: 'review? || approved?'
  validates :gender, inclusion: { in: GENDERS },
              if: 'affect_people && (review? || approved?)'
  validates :geographic_scale, inclusion: { in: 0..3 },
              if: 'review? || approved?'

  validates :license, :source, presence: true

  before_validation :set_fund_slug, :set_duration_funded_months
  before_validation :set_year, unless: :award_year
  before_validation :clear_beneficiary_fields, :clear_districts,
                      if: 'review? || approved?'
  before_save :save_all_age_groups_if_all_ages
  before_save :set_geographic_scale_for_entire_country
  before_save :set_geographic_scale_for_multiple_country

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

  def scrape_grant
    auto_complete
  end

  def before_save_check_regions
    self.district_ids = check_regions(self.districts.pluck(:id))
  end

  # TODO: refactor
  def check_regions(district_ids)
    district_ids = district_ids.reject(&:blank?).map(&:to_i)
    countries    = Country.where(id: District.where(id: district_ids).pluck(:country_id).uniq)
    if countries.count > 1
      self.geographic_scale = 3
      return []
    else
      result = prune_region_districts(district_ids)
      result = check_entire_regions(result)
      result = check_entire_country(result)
      # if all regions OR sub_countries selected then return [] and set country to entire
      # OR multiple if more than one countries
      countries.each do |country|
        unless (country.districts.sub_country_ids - result).count > 0
          result = (result - country.districts.sub_country_ids)
          self.geographic_scale = 2
        end
      end
      return result
    end
  end

  def ages
    if self.age_groups
      return self.age_groups.limit(1) if self.age_groups.include?(AgeGroup.first)
      return self.age_groups
    end
  end

  private

    def set_fund_slug
      self.fund_slug = self.funder.slug + '-' +
                       self.funding_programme.parameterize
    end

    def set_year
      self.award_year = self.award_date.year
    end

    def set_duration_funded_months
      if planned_start_date && planned_end_date
        self.duration_funded_months = (self.planned_end_date.year * 12 + self.planned_end_date.month) - (self.planned_start_date.year * 12 + self.planned_start_date.month)
      end
    end

    def planned_start_date_before_planned_end_date
      if planned_start_date && planned_end_date
        errors.add(:planned_start_date, 'Planned start date must be before planned end date') if planned_start_date > planned_end_date
      end
    end

    def beneficiary_groups
      validate_beneficiary_group('People')
      validate_beneficiary_group('Other')
    end

    def validate_beneficiary_group(group)
      if (self.beneficiary_ids & Beneficiary.where(group: group).pluck(:id)).count < 1
        errors.add(:beneficiaries, 'please select an option') if self.send("affect_#{group.downcase}").present?
      end
    end

    def clear_beneficiary_ids(group)
      self.beneficiaries = self.beneficiaries - Beneficiary.where(group: group)
    end

    def clear_beneficiary_fields
      unless self.affect_people?
        self.gender     = nil
        self.age_groups = []
        clear_beneficiary_ids('People')
      end
      clear_beneficiary_ids('Other') unless self.affect_other?
    end

    def save_all_age_groups_if_all_ages
      if self.age_group_ids.include?(AgeGroup.first.id)
        self.age_group_ids = AgeGroup.pluck(:id)
      end
    end

    def clear_districts
      if self.geographic_scale
        self.districts = [] if self.geographic_scale > 1
      end
    end

    def ensure_districts_for_country
      if self.district_ids.count > 0
        district_country_ids = District.where(id: self.district_ids).pluck(:country_id).uniq
        unless self.country_ids == (district_country_ids & self.country_ids)
          errors.add(:districts, 'not from selected countries')
        end
      end
    end

    def prune_region_districts(district_ids)
      result = []
      # array of names for each region selected
      remove = District.where(id: District.region_ids & district_ids).pluck(:name).uniq
      # array of names for each sub_country selected
      remove_sub = District.where(id: District.sub_country_ids & district_ids).pluck(:name).uniq
      # return array of district_ids without districts of regions selected
      result = district_ids - District.where(region: remove).pluck(:id)
      result = result - District.where(sub_country: remove_sub).pluck(:id)
      return result
    end

    def check_entire_regions(result)
      # check if all districts of a region have been selected
      region_district_counts = District.group(:region).count.except(nil)
      District.where(id: result).group(:region).count.each do |k, v|
        result = (result - District.where(region: k).pluck(:id)) + [District.where(country: countries, name: k).first.id] if region_district_counts[k] == v
      end
      sub_country_district_counts = District.group(:sub_country).count.except(nil)
      District.where(id: result).group(:sub_country).count.each do |k, v|
        result = (result - District.where(sub_country: k).pluck(:id)) + [District.where(country: countries, name: k).first.id] if sub_country_district_counts[k] == v
      end
      self.geographic_scale = 1
      return result
    end

    def check_entire_country(result)
      # check if all regions of a sub_country have been selected
      region_counts = Hash.new(0)
      District.group(:sub_country, :region).uniq.count.map { |k,v| k[0] }.compact.sort.each do |region|
        region_counts[region] += 1
      end
      region_counts.each { |k, v| region_counts[k] = v-1 }
      selected_sub_countries = Hash.new(0)
      District.where(id: result).pluck(:sub_country).compact.each do |sub_country|
        selected_sub_countries[sub_country] += 1
      end
      selected_sub_countries.each do |k, v|
        result = (result - District.where(sub_country: k).pluck(:id)) + [District.where(country: countries, name: k).first.id] if region_counts[k] == v
      end
      return result
    end

    def set_geographic_scale_for_entire_country
      self.geographic_scale = 2 if self.district_ids.count == 0
    end

    def set_geographic_scale_for_multiple_country
      if self.country_ids.count > 1
        self.geographic_scale = 3
        self.district_ids = []
      end
    end

    def set_select(field, amount, segments)
      if amount > segments.last
        return self[field] = segments.length-1
      else
        segments.each_with_index do |num, i|
          return self[field] = i if amount >= segments[i] && amount < segments[i+1]
        end
      end
    end

    def financials_select(field, amount)
      segments = [0, 10000, 100000, 1000000, 10000000]
      set_select(field, amount, segments)
    end

    def staff_select(field, count)
      segments = [0, 1, 6, 26, 51, 101, 251, 500]
      set_select(field, count.to_i, segments)
    end

    def operating_for_select(date)
      age = ((Date.today - date.to_date).to_f / 365)
      if age <= 1
        self.operating_for = 1
      elsif age > 1 && age <= 3
        self.operating_for = 2
      elsif age > 3
        self.operating_for = 3
      end
    end

    def map_charity_commission(mappings)
      result     = []
      background = self.recipient.scrape['background']
      %w[who what how].each do |k|
        if background[k].present?
          background[k].each do |i|
            i = i.to_sym
            result << mappings[i] if mappings[i]
          end
        end
      end
      return result
    end

    def age_group_select
      const = CharityCommissionConstants::AGE_GROUPS
      return AgeGroup.where(label: map_charity_commission(const))
    end

    def beneficiary_select
      const = CharityCommissionConstants::BENEFICIARIES
      return Beneficiary.where(sort: map_charity_commission(const))
    end

    def affect_group?(group)
      ids = Beneficiary.where(group: group).pluck(:id)
      return true if (self.beneficiary_ids & ids).count > 0
    end

    def country_select
      if self.recipient.scrape['data']['regions'].count > 0
        regions = self.recipient.scrape['data']['regions']
        district_countries = District.where(name: regions).pluck(:country_id)
        country_ids = Country.where(name: regions).pluck(:id)
        return (country_ids + district_countries).uniq
      else
        return []
      end
    end

    def district_select
      if self.recipient.scrape['data']['regions'].count > 0
        regions = self.recipient.scrape['data']['regions']
        return District.where('name IN (:regions) OR
                               region IN (:regions) OR
                               sub_country IN (:regions)', regions: regions)
      else
        return []
      end
    end

    def geographic_scale_select
      countries = self.country_ids.uniq
      districts = self.district_ids.uniq
      if countries.count > 1
        return 3
      else
        if countries.count > 0 && districts.count > 0
          country = Country.find(countries.first)
          if (districts & country.districts.pluck(:id)).count == country.districts.count
            return 2
          elsif District.where(id: districts).pluck(:region).uniq.count > 1
            return 1
          else
            return 0
          end
        end
      end
    end

    def auto_complete
      if self.recipient.scrape.keys.count > 1
        background = self.recipient.scrape['background']

        %w[income spending].each do |f|
          if background[f].present?
            self[f] = financials_select(f, background[f])
          else
            self[f] = -1
          end
        end

        if background['incorporated_date'].present?
          self.operating_for = operating_for_select(background['incorporated_date'])
        else
          self.operating_for = -1
        end

        %w[employees volunteers].each do |f|
          if background[f].present?
            self[f] = staff_select(f, background[f])
          else
            self[f] = -1
          end
        end

        self.gender           = 'All genders' # TODO: default?
        self.age_groups       = age_group_select
        self.beneficiaries    = beneficiary_select
        self.affect_people    = affect_group?('People')
        self.affect_other     = affect_group?('Other')
        self.country_ids      = country_select  unless self.countries
        self.districts        = district_select unless self.districts
        self.geographic_scale = geographic_scale_select

        # must select beneficiaries manually if less than 2 auto-selected
        self.beneficiaries.count < 2 ? false : true

        # must select countries or districts if less than scrape regions count
        regions_count = self.recipient.scrape['data']['regions'].count
        self.countries.count < regions_count ? false : true
        self.districts.count < regions_count ? false : true
      end
    end

end
