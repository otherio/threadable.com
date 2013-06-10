class EmailProcessor::ProjectSlugFinder < MethodObject.new(:to)

  def call
    @to.map do |email_address|
      email_address.scan(/^(.+?)@(.+\.)?multifyapp.com$/).try(:first)
    end.flatten.compact.first
  end

end
