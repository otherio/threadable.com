module UnsubscribeToken

  class << self

    def encrypt project_id, user_id, time=Time.now
      nonce = rand(100000000..999999999)
      cleartext_token = [compact(project_id), compact(user_id), compact(time.to_i), compact(nonce)].join(':')
      Base64.urlsafe_encode64(Encryptor.encrypt(cleartext_token, key: key, algorithm: 'bf-ofb'))
    end

    def decrypt token
      cleartext_token = Encryptor.decrypt(Base64.urlsafe_decode64(token), key: key, algorithm: 'bf-ofb')
      project_id, user_id = cleartext_token.split(':').first(2).map{|s| expand(s) }
      [project_id, user_id]
    end

    private

    def key
      @key ||= Digest::SHA256.hexdigest(Multify::Application.config.unsubscribe_token_key)
    end

    def compact string
      string.to_s(36)
    end

    def expand string
      string.to_i(36)
    end

  end

end
