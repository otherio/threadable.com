class VerifyDmarc < MethodObject

  include Dnsruby

  def call email_address
    domain = email_address.domain

    resolver = Dnsruby::Resolver.new
    begin
      query = resolver.query("_dmarc.#{domain}", Types.TXT)
    rescue Dnsruby::NXDomain
      return true
    end

    rdata_records = query.answer.select{|r| r.type == 'TXT'}.map(&:rdata).compact.join(';')
    !rdata_records.include?('p=reject')
  end
end
