class Grant < ActiveRecord::Base

  has_and_belongs_to_many :beneficiaries

  validates :grant_identifier, :funder_identifier, :recipient_identifier, presence: true

  def as_json(options={})
    super(methods: [:beneficiary])
  end

  def beneficiary
    beneficiaries.pluck(:sort)
  end

end
