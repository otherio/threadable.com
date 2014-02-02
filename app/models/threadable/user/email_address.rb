require_dependency 'threadable/user'

class Threadable::User::EmailAddress < Threadable::EmailAddress

  def initialize user, email_address_record
    super(user.threadable, email_address_record)
    @user = user
  end
  attr_reader :user

  def confirm!
    return false if confirmed?
    email_address_record.update!(confirmed_at: Time.now)
    return true
  end

  def primary!
    return false if primary? || !confirmed?
    Threadable.transaction do
      ::EmailAddress.where(user_id: user.id).update_all(primary: false)
      email_address_record.update(primary: true)
    end
    user.user_record.email_addresses.reload
    user.track_update!
    return true
  end

end
