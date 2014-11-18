class VerifyDmarc < MethodObject

  include Dnsruby

  attr_reader :resolver

  def call email_address
    domain = email_address.domain

    # redis_key = "#{self.class}:#{domain}"
    # cached_result = Threadable.redis.get(redis_key)
    # return cached_result unless cached_result.nil?

    @resolver = Dnsruby::Resolver.new
    dmarc_records = dmarc_records("_dmarc.#{domain}").flatten.join(';')
    dns_result = !(dmarc_records.include?('p=reject') || dmarc_records.include?('p=quarantine'))

    # Threadable.redis.set(redis_key, dns_result) and \
    # Threadable.redis.expire(redis_key, 300) # seconds

    dns_result
  end

  private

  def dmarc_records host, depth=0
    return [] if depth > 5

    begin
      query = resolver.query(host, Types.TXT)
    rescue Dnsruby::NXDomain
      return []
    end

    rdata_records = query.answer.select{|r| r.type == 'TXT'}.map(&:rdata).flatten.compact || []

    cname_records = query.answer.select{|r| r.type == 'CNAME'}.map{|r| r.rdata.to_s}.compact
    cname_records.each do |cname|
      rdata_records << dmarc_records(cname, depth + 1)
    end

    return rdata_records
  end
end
