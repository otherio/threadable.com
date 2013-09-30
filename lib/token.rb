module Token

  Invalid = Class.new(ArgumentError)
  TypeMismatch = Class.new(Invalid)

  def self.encrypt(type, payload)
    cleartext_token = Marshal.dump([random, type, payload])
    token = Base64.urlsafe_encode64(Encryptor.encrypt(cleartext_token, key: key, algorithm: 'bf-ofb'))
    return token
  end

  def self.decrypt(expected_type, token)
    begin
      cleartext_token = Encryptor.decrypt(Base64.urlsafe_decode64(token), key: key, algorithm: 'bf-ofb')
    rescue ArgumentError
      raise Invalid, token
    end
    uuid, type, payload = Marshal.load(cleartext_token)
    raise TypeMismatch, type if type != expected_type
    return payload
  end

  def self.key
    @key ||= Digest::SHA256.hexdigest(Covered::Application.config.unsubscribe_token_key)
  end

  def self.random
    rand(9999)
  end

end
