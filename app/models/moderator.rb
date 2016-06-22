class Moderator < ActiveRecord::Base

  belongs_to :approvable, polymorphic: true
  belongs_to :user

  validates :approvable, :user, presence: true
  validate  :ensure_approved

  private

    def ensure_approved
      errors.add(:approvable, 'not approved') if self.approvable.state != 'approved'
    end

end
