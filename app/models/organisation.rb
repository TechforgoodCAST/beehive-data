class Organisation < ActiveRecord::Base

  scope :funders, -> { where(publisher: true) }
  scope :recipients, -> { where(publisher: false) }

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

  validates :organisation_identifier, :slug, uniqueness: true, presence: true
  validates :charity_number, uniqueness: true, if: :charity_number?
  validates :company_number, uniqueness: true, if: :company_number?
  validates :organisation_number, uniqueness: true, if: :organisation_number?
  validates :name, :country, :org_type, :state, presence: true

  validates :publisher, :multi_national, :registered,
              inclusion: { in: [true, false] }, if: 'review? || approved?'
  validates :street_address, :city, :region, :postal_code,
              presence: true, if: 'review? || approved?'
  validates :website, format: { with: URI::regexp(%w(http https)),
              message: 'enter a valid website address e.g. http://www.example.com'},
              if: :website?
  # :legal_name, :company_type, :latitude, :longitude

  before_validation :set_slug, unless: :slug
  before_validation :set_org_type, :set_registered

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

  def as_json(options={})
    super(methods: [:grant_count_as_funder, :grant_count_as_recipient])
  end

  private

  def to_param
    self.slug
  end

  def set_slug
    self.slug = generate_slug
  end

  def generate_slug(n=1)
    return nil unless self.name
    candidate = self.name.parameterize
    candidate += "-#{n}" if n > 1
    return candidate unless Organisation.find_by_slug(candidate)
    generate_slug(n+1)
  end

  def set_org_type
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

  def set_registered
    self.org_type > 0 ? self.registered = true : self.registered = false
    return true
  end

  def grant_count_as_funder
    grants_as_funder.count
  end

  def grant_count_as_recipient
    grants_as_recipient.count
  end

end
