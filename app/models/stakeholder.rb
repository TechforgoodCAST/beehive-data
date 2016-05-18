class Stakeholder < ActiveRecord::Base

  belongs_to :beneficiary
  belongs_to :grant

  validates :beneficiary, :grant, presence: true
  validates :beneficiary, uniqueness: { scope: :grant }

end
