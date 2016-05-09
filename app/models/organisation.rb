class Organisation < ActiveRecord::Base

  has_many :grants_as_funder, class_name: 'Grant', foreign_key: 'funder_id'
  has_many :grants_as_recipient, class_name: 'Grant', foreign_key: 'recipient_id'
  has_one :country

  validates :organisation_identifier, :name, presence: true

  scope :funders, -> { where(publisher: true) }
  scope :recipients, -> { where(publisher: false) }

  def as_json(options={})
    super(methods: [:grant_count_as_funder, :grant_count_as_recipient])
  end

  def grant_count_as_funder
    grants_as_funder.count
  end

  def grant_count_as_recipient
    grants_as_recipient.count
  end

end
