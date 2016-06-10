class District < ActiveRecord::Base

  scope :regions,         -> { pluck(:region).flatten.uniq.compact }
  scope :region_ids,      -> { where(name: District.regions).pluck(:id).uniq }
  scope :sub_countries,   -> { pluck(:sub_country).flatten.uniq.compact }
  scope :sub_country_ids, -> { where(name: District.sub_countries).pluck(:id).uniq }

  belongs_to :country
  has_many :regions
  has_many :grants, through: :regions

  validates :name, presence: true, uniqueness: { scope: :country }
  validates :country, presence: true

end
