module OrganizationResubscribeToken

  def self.encrypt organization_id, member_id
    Token.encrypt(name, [organization_id, member_id])
  end

  def self.decrypt token
    Token.decrypt(name, token)
  end

end
