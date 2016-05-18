class Region < ActiveRecord::Base

  belongs_to :district
  belongs_to :grant

  validates :district, :grant, presence: true
  validates :district, uniqueness: { scope: :grant }
  validate :ensure_districts_for_country

  private

  def ensure_districts_for_country
    unless self.grant.country_ids.include?(self.district.country_id)
      errors.add(:district, 'Not a district of grant')
    end
  end

end
