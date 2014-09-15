class AddressList < MethodObject

  def call *strings
    email_addresses = strings.compact.join(', ')

    begin
      Mail::AddressList.new(email_addresses).addresses
    rescue Mail::Field::ParseError
      # sometimes people remove the quotes and leave the colon, or the phrase part contains unsupported unicode.
      # so, this works around shortcomings in Mail's AddressListParser
      email_addresses = email_addresses.to_ascii
      email_addresses.gsub!(/:/, '')

      # also, Mail doesn't allow a comma in the phrase part.
      # this is fucked up. like mediawiki style. it hurts me.
      # TODO: fix Mail's address list parser so it can't do this to us anymore
      email_addresses.gsub!(/(\@[\w\d\.\s]+),/, '\1__COMMA__')
      email_addresses.gsub!(/(?<!>),/, '')
      email_addresses.gsub!(/__COMMA__/, ',')

      Mail::AddressList.new(email_addresses).addresses
    end

  end

end
