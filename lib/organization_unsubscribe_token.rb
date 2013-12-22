module OrganizationUnsubscribeToken

  def self.encrypt project_id, user_id
    Token.encrypt(name, [project_id, user_id])
  end

  def self.decrypt token
    Token.decrypt(name, token)
  end

end
