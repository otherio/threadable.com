module User::Password

  extend ActiveSupport::Concern

  included do
    has_secure_password validations: false

    validates :password,
      presence: true,
      length: { minimum: 6, maximum: 128 },
      confirmation: true,
      if: :validate_password?

    validates :password_confirmation, presence: true, if: :validate_password?

    scope :with_password, ->{ where("users.encrypted_password <> ''") }

    scope :without_password, ->{ where encrypted_password: "" }
  end

  attr_accessor :password, :password_confirmation

  def password_digest
    encrypted_password
  end

  def password_digest= password_digest
    self.encrypted_password = password_digest
  end

  def valid_password? password
    return false if encrypted_password.blank?
    bcrypt   = ::BCrypt::Password.new(encrypted_password)
    password = ::BCrypt::Engine.hash_secret(password.to_s, bcrypt.salt)
    return false if password.blank? || encrypted_password.blank? || password.bytesize != encrypted_password.bytesize
    l = password.unpack "C#{password.bytesize}"
    res = 0
    encrypted_password.each_byte { |byte| res |= byte ^ l.shift }
    res == 0
  end

  def authenticate password
    self if valid_password? password
  end

  def has_password?
    encrypted_password.present?
  end

  private

  def validate_password?
    encrypted_password_changed?
  end

end
