class ExtractEmailAddresses < MethodObject

  def call *strings
    Mail::AddressList.new(strings.map(&:to_s).join(', ')).addresses.map(&:address)
  end

end
