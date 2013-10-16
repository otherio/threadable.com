class Authentication

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  # include ActiveModel::Validations
  def persisted?; false; end
  include Virtus

  attribute :user,        User
  attribute :email,       String
  attribute :password,    String
  attribute :remember_me, Boolean, :default => false

  def valid?
    errors.clear
    return true if user.present?
    if email.blank? || password.blank?
      errors.add(:base, 'please enter an email address and password')
      return false
    end
    user = User.with_email(email.downcase).first
    if user.nil? || !user.authenticate(password)
      return false
    end
    !!self.user = user
  end

  def errors
    @errors ||= ActiveModel::Errors.new(self)
  end

  def == other
    attributes == other.attributes
  end

end
