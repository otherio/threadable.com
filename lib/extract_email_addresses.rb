class ExtractEmailAddresses < MethodObject

  def call *strings
    Mail::AddressList.new(strings.compact.map { |string| filter_invalid_characters(string) }.join(', ')).addresses.map(&:address)
  end

  def filter_invalid_characters string
    string = string.to_ascii if string =~ /[^\u0000-\u007F]/
    string.gsub(/[:,]/, '')
  end

end
