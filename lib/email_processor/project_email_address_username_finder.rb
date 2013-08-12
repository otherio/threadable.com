class EmailProcessor::ProjectEmailAddressUsernameFinder < MethodObject.new(:to)

  def call
    @to.map do |email_address|
      email_address.scan(/^(.+?)@(.+\.)?covered.io$/).try(:first)
    end.flatten.compact.first
  end

end
