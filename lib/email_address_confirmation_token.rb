module EmailAddressConfirmationToken

  def self.encrypt email_address_id
    Token.encrypt(name, email_address_id.to_i)
  end

  def self.decrypt token
    Token.decrypt(name, token)
  end

end
