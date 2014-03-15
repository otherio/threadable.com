class Threadable::Integrations::TrelloProcessor < MethodObject
  def call incoming_integration_hook
    @incoming_integration_hook = incoming_integration_hook
    @params = incoming_integration_hook.params
    @organization = incoming_integration_hook.organization
    @group = incoming_integration_hook.group
    @threadable = incoming_integration_hook.threadable

    @action = params['action']['type']

    if action == 'createCard'
      create_conversation!
    end

  end

  attr_reader :params, :organization, :group, :action, :threadable

  def create_conversation!
    @incoming_integration_hook.conversation = organization.conversations.create!(
      subject:    subject,
      creator_id: creator.try(:id),
      groups:     [group],
    )
  end

  def creator
    user_id = threadable.external_authorizations.find_by_unique_id(params['action']['memberCreator']['id']).user_id

    if user_id.present?
      threadable.users.find_by_id(user_id)
    end
  end

  def subject
    params['action']['data']['card']['name']
  end

end
