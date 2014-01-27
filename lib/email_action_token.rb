module EmailActionToken

  def self.encrypt conversation_id, user_id, action
    Token.encrypt(name, [conversation_id, user_id, action])
  end

  def self.decrypt token
    Token.decrypt(name, token)
  end

end
