class Covered::EmailAddresses < Covered::Collection

  def all
    scope.reload.map{|email_address_record| email_address_for email_address_record }
  end

  def create attributes={}
    Create.call(self, attributes)
  end

  def create! attributes={}
    email_address = create(attributes)
    email_address.persisted? or raise Covered::RecordInvalid, "EmailAddress invalid: #{email_address.errors.full_messages.to_sentence}"
    email_address
  end

  private

  def scope
    ::EmailAddress.all
  end

  def email_address_for email_address_record
    Covered::EmailAddress.new(covered, email_address_record)
  end

end
