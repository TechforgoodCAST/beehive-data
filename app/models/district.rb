class District < ActiveRecord::Base

  belongs_to :country
  has_many :regions
  has_many :grants, through: :regions

  validates :name, presence: true, uniqueness: { scope: :country }
  validates :country, :subdivision, presence: true

end
