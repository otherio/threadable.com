class ExtractEmailAddresses < MethodObject

  def call *strings
    AddressList.call(strings).map(&:address)
  end

end
