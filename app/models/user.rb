class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :registerable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable,
         :trackable, :validatable

  before_create :set_api_token

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

end
