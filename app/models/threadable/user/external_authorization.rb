class Threadable::User::ExternalAuthorization < Threadable::Model

  self.model_name = ::ExternalAuthorization.model_name

  def initialize user, external_authorization_record
    @user, @threadable, @external_authorization_record = user, user.threadable, external_authorization_record
  end
  attr_reader :threadable, :external_authorization_record, :user

  delegate *%w{
    id
    user_id
    provider
    token
    secret
  }, to: :external_authorization_record

  def to_s
    "#{user_id}:#{provider}"
  end

  def == other
    id.nil? ? (self.class === other && other.id == id) : (other.to_s == self.to_s)
  end

  def inspect
    %(#<#{self.class} user_id: #{user_id.inspect}, provider: #{provider.inspect}, token: #{token.inspect}>)
  end

end
