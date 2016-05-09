class Country < ActiveRecord::Base

  belongs_to :organisation
  has_many :districts
  has_and_belongs_to_many :grants

  validates :name, :alpha2, presence: true, uniqueness: true

end
