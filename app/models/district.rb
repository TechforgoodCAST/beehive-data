class District < ActiveRecord::Base

  belongs_to :country
  has_and_belongs_to_many :grants

  validates :country, :name, presence: true, uniqueness: { scope: :country }

end
