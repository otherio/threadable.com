module AccountRequestConfirmationToken

  def self.encrypt account_request_id
    Token.encrypt(name, account_request_id)
  end

  def self.decrypt token
    Token.decrypt(name, token)
  end

end
