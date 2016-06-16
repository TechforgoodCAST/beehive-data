class Award < ActiveRecord::Base

  belongs_to :grant
  belongs_to :recipient, class_name: 'Organisation'

  validates :grant, :recipient, presence: true
  validates :amount_awarded, presence: true

end
