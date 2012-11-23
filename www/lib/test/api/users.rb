class Test::Api::Users

  def self.create attributes
    @users ||= []
    user = User.new(attributes)
    @users << user
    user
  end

  def self.find email
    @users ||= []
    @users.find{|user| user.email == email } || create(email: email)
  end

end
