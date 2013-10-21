module ResetPasswordToken

  def self.encrypt user_id
    Token.encrypt(name, user_id)
  end

  def self.decrypt token
    Token.decrypt(name, token)
  end

end
