class NewOrganization::Member

  include Virtus
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  def persisted?; false; end

  attribute :name,          String
  attribute :email_address, String


  validates_presence_of :name
  validates_presence_of :email_address

  validate :validate_email_address!

  private

  def validate_email_address!
    ValidateEmailAddress.call(email_address) and return
    errors.add(:email_address, 'is invalid')
  end
end
