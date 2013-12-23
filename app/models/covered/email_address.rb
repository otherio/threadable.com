class Covered::EmailAddress < Covered::Model

  self.model_name = ::EmailAddress.model_name

  def initialize covered, email_address_record
    @covered, @email_address_record = covered, email_address_record
  end
  attr_reader :covered, :email_address_record

  delegate *%w{
    id
    address
    user_id
    primary?
    errors
    persisted?
    confirmed?
  }, to: :email_address_record

  def formatted_email_address
    user.nil? ? address : "#{user.name} <#{address}>"
  end

  def confirm!
    email_address_record.update(confirmed_at: Time.now)
  end

  def to_key
    id ? [id] : nil
  end

  def to_s
    address.to_s
  end
  alias_method :to_str, :to_s

  def to_param
    address
  end

  def user
    @user ||= covered.users.find_by_id(user_id) if user_id
  end

  def == other
    id.nil? ? (self.class === other && other.id == id) : (other.to_s == self.to_s)
  end

  def inspect
    %(#<#{self.class} address: #{address.inspect}, primary: #{primary?.inspect}, confirmed: #{confirmed?.inspect}>)
  end

end
