class Age < ActiveRecord::Base

  belongs_to :age_group
  belongs_to :grant

  validates :age_group, :grant, presence: true
  validates :age_group, uniqueness: { scope: :grant }

end
