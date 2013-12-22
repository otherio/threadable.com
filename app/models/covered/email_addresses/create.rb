require_dependency 'covered/email_address'

class Covered::EmailAddresses::Create < MethodObject

  def call email_addresses, attributes
    covered = email_addresses.covered
    scope = email_addresses.send(:scope)
    email_address_record = scope.create(attributes)
    Covered::EmailAddress.new(covered, email_address_record)
  end

end
