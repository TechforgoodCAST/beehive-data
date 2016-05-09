class AgeGroup < ActiveRecord::Base

  has_and_belongs_to_many :grants

  validates :label, :age_from, :age_to, presence: true, uniqueness: true

end
