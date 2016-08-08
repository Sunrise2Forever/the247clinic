class User < ActiveRecord::Base
  attr_accessor :remember_token, :activation_token, :reset_token, :password_confirmation
  before_save :downcase_email
  before_save :create_activation_digest
  validates :name,  presence: true, length: { maximum: 50 }
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  has_many :video_sessions, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :favorite_clinics, dependent: :destroy
  has_many :favorite_doctors, dependent: :destroy
  has_many :appointments, dependent: :destroy
  has_many :not_working_dates, dependent: :destroy
  has_many :working_schedules
  accepts_nested_attributes_for :working_schedules, reject_if: :all_blank, allow_destroy: true

  belongs_to :clinic

  after_create :generate_authentication_token!

  def generate_authentication_token!
    self.authentication_token = Digest::SHA1.hexdigest("#{Time.now}-#{self.id}-#{self.updated_at}")
    self.save
  end

  # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
   
  # Returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def doctor?
    user_type == 'doctor'
  end

  def patient?
    user_type == 'patient'
  end

  def csr?
    user_type == 'csr'
  end

  def user_type_string
    self.admin? ? 'Admin' : (self.user_type.try(:capitalize) || 'Patient')
  end


  def not_working_days
    if read_attribute(:not_working_days).is_a?(String)
      read_attribute(:not_working_days).split(',')
    else
      super
    end
  end

  def not_working_days=(val)
    if val.is_a?(Array)
      self.not_working_days = val.join(',')
    else
      super
    end
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  # Returns true if the given token matches the digest.
  def authenticated?(remember_token)
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end
  
  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end  

  # Returns true if the given token matches the digest.
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Activates an account.
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end
  
    # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end
  
  private

    # Converts email to all lower-case.
    def downcase_email
      self.email = email.downcase
    end

    # Creates and assigns the activation token and digest.
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
