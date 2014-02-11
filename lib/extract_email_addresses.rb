class ExtractEmailAddresses < MethodObject

  def call *strings
    Mail::AddressList.new(strings.map { |string| string.to_ascii.gsub(/:/, '') }.join(', ')).addresses.map(&:address)
  end

end
