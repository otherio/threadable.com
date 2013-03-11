class UnsubscribeToken
  attr_reader :token, :user_id, :project_id, :time

  def initialize(params)
    if params[:token]
      @token = params[:token]
      decrypt
    else
      @user_id = params[:user_id]
      @project_id = params[:project_id]
      encrypt
    end
  end

  private

  def decrypt
    cleartext_token = Encryptor.decrypt(Base64.urlsafe_decode64(@token), key: key, algorithm: 'bf-ofb')
    @user_id, @project_id, epoch, _ = cleartext_token.split(':').map {|thing| thing.to_i(36)}
    @time = Time.at(epoch)
  end

  def encrypt
    nonce = Random.new.rand(100000000..999999999)

    cleartext_token = [@user_id.to_s(36), @project_id.to_s(36), Time.now.to_i.to_s(36), nonce.to_s(36)].join(':')
    @token = Base64.urlsafe_encode64(Encryptor.encrypt(cleartext_token, key: key, algorithm: 'bf-ofb'))
  end

  def key
    Digest::SHA256.hexdigest(Multify::Application.config.unsubscribe_token_key)
  end
end
