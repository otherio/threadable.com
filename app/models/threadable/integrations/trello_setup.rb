class Threadable::Integrations::TrelloSetup < MethodObject
  include Rails.application.routes.url_helpers

  def call group
    @threadable = group.threadable
    @auth = threadable.current_user.external_authorizations.for_provider('trello')
    return unless @auth.present?

    board_id = group.integration_params['id']
    board = user_client.find(:boards, board_id)
    return unless board.present?

    user_client.create(
      :webhook,
      'description' => 'Threadable',
      'callbackURL' => integration_hook_url(provider: 'trello', organization_id: group.organization.slug, group_id: group.slug),
      'idModel'     => board_id,
    )

  end

  attr_reader :auth, :threadable

  def user_client
    @user_client ||= Trello::Client.new(
      consumer_key:       auth.application_key,
      consumer_secret:    auth.application_secret,
      oauth_token:        auth.token,
      oauth_token_secret: auth.secret,
    )
  end

  def threadable_client
    @threadable_client ||= Trello::Client.new(
      consumer_key:       auth.application_key,
      consumer_secret:    auth.application_secret,
      oauth_token:        auth.threadable_token
    )
  end

  def default_url_options
    { host: threadable.host, port: threadable.port }
  end

end
