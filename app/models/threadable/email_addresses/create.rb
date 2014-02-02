require_dependency 'threadable/email_address'

class Threadable::EmailAddresses::Create < MethodObject

  def call email_addresses, attributes
    threadable = email_addresses.threadable
    scope = email_addresses.send(:scope)
    email_address_record = scope.create(attributes)
    Threadable::EmailAddress.new(threadable, email_address_record)
  end

end
