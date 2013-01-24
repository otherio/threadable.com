class Session
  extend ActiveModel::Naming
  include Virtus
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attribute :email,    String
  attribute :password, String

  validates_presence_of :email
  validates_presence_of :password
  validate :validate_presence_of_user
  validate :validate_password

  def persisted?
    false
  end

  def user
    @user ||= User.find_by_email(email)
  end

  private

  def validate_presence_of_user
    user.present? or errors.add(:email, 'a user with that email address was not found')
  end

  def validate_password
    password == 'password' or errors.add(:password, 'is not "password"')
  end

end
