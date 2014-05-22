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
    errors
  }, to: :external_authorization_record

  def application_key
    ENV['THREADABLE_TRELLO_API_KEY'] if provider == 'trello'
    ENV['GOOGLE_CLIENT_ID'] if provider == 'google_oauth2'
  end

  def pretty_provider
    case provider
    when 'trello'
      'Trello'
    when 'google_oauth2'
      'Google'
    end
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
