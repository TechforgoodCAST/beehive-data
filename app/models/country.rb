class Country < ActiveRecord::Base

  has_many :districts
  has_many :locations
  has_many :grants, through: :locations

  # validates :name, :alpha2, presence: true, uniqueness: true

end
