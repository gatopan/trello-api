module PersonDecorator
  extend ActiveSupport::Concern

  included do
    has_secure_password validations: false
    before_validation :generate_token,                               on: :create

    enum role: {
      GUEST:  0,
      ALUMN:  10,
      MENTOR: 20,
      ADMIN:  30,
    }

    validates :name,                                              presence: true
    validates :email,              presence: true, uniqueness: true, email: true
    validates :password,                                      confirmation: true
    validates :role,                                              presence: true
    validates :token,                           presence: true, uniqueness: true
  end

  def generate_token
    loop do
      self.token = SecureRandom.hex
      break unless self.class.exists?(token: token)
    end
  end

  module ClassMethods
    def test_class_method
      puts 'class method yay'
    end
  end
end
