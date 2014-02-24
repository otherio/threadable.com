module SignUpConfirmationToken

  def self.encrypt organization_name, email_address
    Token.encrypt(name, [organization_name.to_s, email_address.to_s])
  end

  def self.decrypt token
    Token.decrypt(name, token)
  end

end
