class Test::Api::User

  include Virtus

  attribute :name, String
  attribute :email, String
  attribute :password, String

  def self.create attributes
    @users ||= []
    user = new(attributes)
    @users << user
    user
  end

  def self.find email
    @users ||= []
    @users.find{|user| user.email == email } || create(email: email)
  end

end
