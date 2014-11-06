class Threadable::EmailAddress < Threadable::Model

  class << self
    delegate :normalize, to: ::EmailAddress
  end

  self.model_name = ::EmailAddress.model_name

  def initialize threadable, email_address_record
    @threadable, @email_address_record = threadable, email_address_record
  end
  attr_reader :threadable, :email_address_record

  delegate *%w{
    id
    user_id
    primary?
    errors
    persisted?
    confirmed?
    reload
  }, to: :email_address_record

  def address
    email_address_record.address.try(:downcase)
  end

  def formatted_email_address
    FormattedEmailAddress.new(display_name: user.try(:name), address: address).to_s
  end

  def confirm!
    email_address_record.update(confirmed_at: Time.now)
  end

  def to_s
    address.to_s
  end
  alias_method :to_str, :to_s

  def to_param
    address
  end

  def user
    @user ||= threadable.users.find_by_id(user_id) if user_id
  end

  def == other
    id.nil? ? (self.class === other && other.id == id) : (other.to_s == self.to_s)
  end

  def inspect
    %(#<#{self.class} address: #{address.inspect}, primary: #{primary?.inspect}, confirmed: #{confirmed?.inspect}>)
  end

end
