class Beneficiary < ActiveRecord::Base

  has_and_belongs_to_many :grants

  validates :sort, presence: true

end
