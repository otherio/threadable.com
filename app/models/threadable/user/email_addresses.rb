require_dependency 'threadable/user'
require_dependency 'threadable/user/email_address'

class Threadable::User::EmailAddresses < Threadable::EmailAddresses

  def initialize user
    @user    = user
    @threadable = user.threadable
  end
  attr_reader :user

  def primary
    if user.user_record.email_addresses.loaded?
      email_address_for user.user_record.primary_email_address
    else
      email_address_for (scope.primary.first or return)
    end
  end

  def add email_address, primary=false
    Threadable.transaction do
      email_address = email_address_for create(address: email_address)
      email_address.primary! if primary
    end
    email_address
  end

  def add! email_address, primary=false
    email_address = add(email_address, primary)
    email_address.persisted? or raise Threadable::RecordInvalid, "user email address invalid: #{email_address.errors.full_messages.to_sentence}"
    email_address
  end

  def inspect
    %(#<#{self.class} user_id: #{user.id}>)
  end

  private

  def scope
    user.user_record.email_addresses.unload
  end

  def email_address_for email_address_record
    Threadable::User::EmailAddress.new(user, email_address_record) if email_address_record
  end

end
