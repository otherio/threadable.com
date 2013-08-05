module ProjectResubscribeToken

  def self.encrypt project_membership_id
    Token.encrypt(name, project_membership_id)
  end

  def self.decrypt token
    Token.decrypt(name, token)
  end

end
