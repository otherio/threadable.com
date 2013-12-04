class Covered::User::EmailAddress < Covered::EmailAddress

  def initialize user, email_address_record
    super(user.covered, email_address_record)
    @user = user
  end
  attr_reader :user

  def primary!
    return false if primary?
    ::EmailAddress.transaction do
      ::EmailAddress.where(user_id: user.id).update_all(primary: false)
      email_address_record.update(primary: true)
    end
    user.user_record.email_addresses.reload
    user.track_update!
    return true
  end

end
