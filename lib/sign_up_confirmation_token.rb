module SignUpConfirmationToken

  def self.encrypt email_address
    Token.encrypt(name, email_address.to_s)
  end

  def self.decrypt token
    Token.decrypt(name, token)
  end

end
