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
    name
    email_address
    nickname
    url
    unique_id
  }, to: :external_authorization_record

  def application_key
    ENV['THREADABLE_TRELLO_API_KEY'] if provider == 'trello'
  end

  def application_secret
    ENV['THREADABLE_TRELLO_API_SECRET'] if provider == 'trello'
  end

  def threadable_token
    ENV['THREADABLE_TRELLO_USER_TOKEN'] if provider == 'trello'
  end

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
