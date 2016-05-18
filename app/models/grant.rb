class Grant < ActiveRecord::Base

  belongs_to :funder, class_name: 'Organisation'
  belongs_to :recipient, class_name: 'Organisation'
  has_and_belongs_to_many :age_groups
  has_and_belongs_to_many :beneficiaries
  has_and_belongs_to_many :countries
  has_and_belongs_to_many :districts

  validates :grant_identifier, :funder, :recipient, :state, :title, :description,
            :currency, :funding_programme, :amount_awarded, :award_date,
              presence: true
  validates :grant_identifier, uniqueness: true

  validates :age_groups, presence: true, if: 'review? || approved?'

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
    super(methods: [:funder_name, :recipient_name, :beneficiary])
  end

  private

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
