class Authentication

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  # include ActiveModel::Validations
  def persisted?; false; end
  include Virtus

  def initialize covered, atrributes
    @covered = covered
    super(atrributes)
  end
  attr_reader :covered

  attribute :user,          User
  attribute :email_address, String
  attribute :password,      String
  attribute :remember_me,   Boolean, :default => true

  def valid?
    errors.clear
    return true if user.present?
    if email_address.blank? || password.blank?
      errors.add(:base, 'please enter an email address and password')
      return false
    end
    user = covered.users.find_by_email_address(email_address.downcase)
    if user.nil? || !user.web_enabled? || !user.authenticate(password)
      errors.add(:base, 'Bad email address or password')
      return false
    end
    self.user = user
    return true
  rescue BCrypt::Errors::InvalidHash
    return false
  end

  def errors
    @errors ||= ActiveModel::Errors.new(self)
  end

  def == other
    attributes == other.attributes
  end
  alias_method :eql?, :==

end
