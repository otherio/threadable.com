module MailgunSignature

  def self.api_key
    Covered.config('mailgun')['key']
  end

  def self.encode(timestamp, token)
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new('SHA256'), api_key, [timestamp, token].join)
  end

end
