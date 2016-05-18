class Location < ActiveRecord::Base

  belongs_to :country
  belongs_to :grant

  validates :country, :grant, presence: true
  validates :country, uniqueness: { scope: :grant }

end
