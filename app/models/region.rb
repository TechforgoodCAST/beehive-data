class Region < ActiveRecord::Base

  belongs_to :district
  belongs_to :grant

  validates :district, :grant, presence: true
  validates :district, uniqueness: { scope: :grant }

end
