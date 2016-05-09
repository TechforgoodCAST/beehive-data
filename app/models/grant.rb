class Grant < ActiveRecord::Base

  belongs_to :funder, class_name: 'Organisation'
  belongs_to :recipient, class_name: 'Organisation'
  has_and_belongs_to_many :age_groups
  has_and_belongs_to_many :beneficiaries
  has_and_belongs_to_many :countries
  has_and_belongs_to_many :districts

  validates :grant_identifier, :funder, :recipient, presence: true

  def as_json(options={})
    super(methods: [:funder_name, :recipient_name, :beneficiary])
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
