class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :registerable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable,
         :trackable, :validatable

  scope :admin,     -> { where(role: 'admin') }
  scope :moderator, -> { where(role: 'moderator') }

  has_many :moderators
  has_many :grants, through: :moderators, source: :approvable, source_type: 'Grant'
  has_many :organisations, through: :moderators, source: :approvable, source_type: 'Organisation'

  validates :first_name, :last_name, :initials, presence: true
  validates :role, inclusion: { in: %w[moderator admin] }

  before_validation :set_initials
  before_create :set_api_token

  def self.ids(instance, current_user)
    return (instance.user_ids + [current_user.id]).uniq
  end

  def admin?
    return self.role == 'admin'
  end

  private

    def set_api_token
      return if api_token.present?
      self.api_token = generate_api_token
    end

    def generate_api_token
      loop do
        token = SecureRandom.hex
        break token unless self.class.exists?(api_token: token)
      end
    end

    def set_initials
      if self.first_name && self.last_name
        self.initials = self.first_name[0] + self.last_name[0].upcase
      end
    end

end
