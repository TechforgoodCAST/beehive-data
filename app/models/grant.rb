class Grant < ActiveRecord::Base

  scope :import,   -> { where(state: 'import') }
  scope :review,   -> { where(state: 'review') }
  scope :approved, -> { where(state: 'approved') }

  VALID_YEARS = (Date.today.year-10..Date.today.year).to_a
  GENDERS = ['All genders', 'Female', 'Male', 'Transgender', 'Other']
  OPERATING_FOR = [
    ['Yet to start', 0],
    ['Less than 12 months', 1],
    ['Less than 3 years', 2],
    ['4 years or more', 3]
  ]
  INCOME = [
    ['Less than £10k', 0],
    ['£10k - £100k', 1],
    ['£100k - £1m', 2],
    ['£1m - £10m', 3],
    ['£10m+', 4]
  ]
  EMPLOYEES = [
    ['None', 0],
    ['1 - 5', 1],
    ['6 - 25', 2],
    ['26 - 50', 3],
    ['51 - 100', 4],
    ['101 - 250', 5],
    ['251 - 500', 6],
    ['500+', 7]
  ]

  belongs_to :funder, class_name: 'Organisation'
  belongs_to :recipient, class_name: 'Organisation'

  has_many :locations
  has_many :countries, through: :locations
  has_many :regions
  has_many :districts, through: :regions

  has_many :ages
  has_many :age_groups, through: :ages
  has_many :stakeholders
  has_many :beneficiaries, through: :stakeholders

  validates :grant_identifier, uniqueness: true
  validates :grant_identifier, :funder, :recipient, :state, :year,
            :title, :description, :currency, :funding_programme,
            :amount_awarded, :award_date,
              presence: true
  validates :year, inclusion: { in: VALID_YEARS }

  # validates :age_groups, :beneficiaries, :countries, :districts,
  #             presence: true, if: 'review? || approved?'
  validates :affect_people, :affect_other, inclusion: { in: [true, false] },
              if: 'review? || approved?'
  validates :operating_for, inclusion: { in: 0..3 },
              if: 'review? || approved?'
  validates :income, inclusion: { in: 0..4 },
              if: 'review? || approved?'
  validates :employees, :volunteers, inclusion: { in: 0..7 },
              if: 'review? || approved?'
  validates :gender, inclusion: { in: GENDERS },
              if: 'review? || approved?'

  before_validation :set_year, unless: :year

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

  def as_json(options={})
    super(methods: [:funder_name, :recipient_name, :beneficiary])
  end

  private

    # TODO: refactor
    def income_select(income)
      if income < 10000
        self.income = 0
      elsif income >= 10000 && income < 100000
        self.income = 1
      elsif income >= 100000 && income < 1000000
        self.income = 2
      elsif income >= 1000000 && income < 10000000
        self.income = 3
      elsif income >= 10000000
        self.income = 4
      else
        self.income = nil
      end
    end

    def auto_complete
      if self.recipient.scrape.keys.count > 1
        self.income = income_select(self.recipient.scrape['background']['income'])
      end

      # self.income = 1
      # org_type, :age_groups, :beneficiaries, :countries, :districts
    end

    def set_year
      self.year = self.award_date.year
    end

    def funder_name
      funder.name
    end

    def recipient_name
      recipient.name
    end

    def beneficiary
      beneficiaries.pluck(:sort)
    end

end
