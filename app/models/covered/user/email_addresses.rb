require_dependency 'covered/user'
require_dependency 'covered/user/email_address'

class Covered::User::EmailAddresses < Covered::EmailAddresses

  def initialize user
    @user    = user
    @covered = user.covered
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
    Covered.transaction do
      email_address = email_address_for create(address: email_address)
      email_address.primary! if primary
    end
    email_address
  end

  def add! email_address, primary=false
    email_address = add(email_address, primary)
    email_address.persisted? or raise Covered::RecordInvalid, "user email address invalid: #{email_address.errors.full_messages.to_sentence}"
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
    Covered::User::EmailAddress.new(user, email_address_record) if email_address_record
  end

end
