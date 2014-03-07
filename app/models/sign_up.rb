class SignUp

  include Virtus
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  def persisted?; false; end

  def initialize threadable, attributes={}
    @threadable = threadable
    super(attributes)
  end
  attr_reader :threadable

  attribute :email_address,     String
  attribute :organization_name, String

  validates :email_address,     presence: true, email: true
  validates :organization_name, presence: true

  def existing_user?
    @existing_user ||= threadable.email_addresses.find_by_address(email_address).present?
  end

end
