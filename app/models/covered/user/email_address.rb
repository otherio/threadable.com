class Covered::User::EmailAddress

  def initialize current_user, email_address_record
    @current_user, @email_address_record = current_user, email_address_record
  end
  attr_reader :current_user, :email_address_record
  delegate :covered, to: :current_user

  delegate *%w{
    address
    primary?
    errors
    persisted?
  }, to: :email_address_record


  def primary!
    return false if primary?
    current_user.user_record.transaction do
      current_user.user_record.email_addresses.update_all(primary: false)
      email_address_record.update(primary: true)
    end
    current_user.track_update!
    return true
  end


  def inspect
    %(#<#{self.class} user_id: #{current_user.id.inspect}, address: #{address.inspect} primary: #{primary?}>)
  end

  def == other
    self.class === other && other.id == id
  end

end
