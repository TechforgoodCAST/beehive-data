class Beneficiary < ActiveRecord::Base

  has_and_belongs_to_many :grants

  validates :label, :sort, :group, presence: true
  validates :label, :sort, uniqueness: true
  
end
