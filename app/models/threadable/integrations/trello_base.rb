class Threadable::Integrations::TrelloBase < MethodObject

  def auth
    group.integration_user.external_authorizations.for_provider('trello')
  end

  def client
    @client ||= Trello::Client.new(
      consumer_key:       auth.application_key,
      consumer_secret:    auth.application_secret,
      oauth_token:        auth.token,
      oauth_token_secret: auth.secret,
    )
  end

  def default_url_options
    { host: threadable.host, port: threadable.port }
  end

end
