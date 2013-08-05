module UserSetupToken

  def self.encrypt user_id, destination_path
    Token.encrypt(name, [user_id, destination_path])
  end

  def self.decrypt token
    Token.decrypt(name, token)
  end

end
