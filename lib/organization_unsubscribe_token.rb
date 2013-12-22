module OrganizationUnsubscribeToken

  def self.encrypt organization_id, user_id
    Token.encrypt(name, [organization_id, user_id])
  end

  def self.decrypt token
    Token.decrypt(name, token)
  end

end
