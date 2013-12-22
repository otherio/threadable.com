module OrganizationResubscribeToken

  def self.encrypt project_id, member_id
    Token.encrypt(name, [project_id, member_id])
  end

  def self.decrypt token
    Token.decrypt(name, token)
  end

end
