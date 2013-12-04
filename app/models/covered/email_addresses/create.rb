class Covered::EmailAddresses::Create < MethodObject

  def call email_addresses, attributes
    @scope = email_addresses.send(:scope)
    @email_address_record = @scope.create(attributes)
    return @email_address_record
  end

end
