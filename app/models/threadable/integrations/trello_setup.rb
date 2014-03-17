class Threadable::Integrations::TrelloSetup < Threadable::Integrations::TrelloBase
  include Rails.application.routes.url_helpers

  def call group
    @threadable = group.threadable
    @current_user = threadable.current_user
    return unless auth.present?

    board_id = group.integration_params['id']

    hook = client.create(
      :webhook,
      'description' => 'Threadable',
      'callbackURL' => integration_hook_url(provider: 'trello', organization_id: group.organization.slug, group_id: group.slug),
      'idModel'     => board_id,
    )

    group.integration_user = current_user if hook
  end

  attr_reader :threadable, :current_user

end
