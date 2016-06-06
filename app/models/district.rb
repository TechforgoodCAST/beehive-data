class District < ActiveRecord::Base

  belongs_to :country
  has_many :regions
  has_many :grants, through: :regions

  validates :name, presence: true, uniqueness: { scope: :country }
  validates :country, presence: true

  def self.regions_and_sub_countries
    return District.pluck(:sub_country, :region).flatten.uniq.reject { |i| i == nil }
  end

  def self.districts_options
    hash = {}
    self.regions_and_sub_countries.each { |i| hash[i] = i }
    return District.pluck(:name, :id) + hash.to_a
  end

end
