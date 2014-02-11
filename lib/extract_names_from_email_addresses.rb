class ExtractNamesFromEmailAddresses < MethodObject

  def call email_addresses
    email_addresses = Mail::AddressList.new(email_addresses.compact.map { |address| address.to_ascii.gsub(/:/, '') }.join(', ')).addresses
    email_addresses.map do |email_address|
      next email_address.name.split(/\s+/).first if email_address.name.present?
      next email_address.address.split('@').first.split('.').first
    end
  end

end
