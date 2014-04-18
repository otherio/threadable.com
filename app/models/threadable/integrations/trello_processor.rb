class Threadable::Integrations::TrelloProcessor < Threadable::Integrations::TrelloBase
  def call incoming_integration_hook
    @incoming_integration_hook = incoming_integration_hook
    @organization = incoming_integration_hook.organization
    @group = incoming_integration_hook.group
    @action = incoming_integration_hook.params['integration_hook']['action']
    @threadable = incoming_integration_hook.threadable

    case action['type']
    when 'createCard'
      find_or_create_conversation!
    when 'updateCard'
      return unless action['data'].has_key?('old') && action['data']['old'].has_key?('desc')
      find_or_create_conversation!
      body = "#{action['data']['card']['desc']}<br>(I updated this card's description.)"
      create_message_with_body!(body)
    when 'commentCard'
      find_or_create_conversation!
      create_message_with_body!(action['data']['text'])
    else
      #unsupported action.
      return
    end
  end

  attr_reader :organization, :group, :action, :threadable, :conversation

  def find_or_create_conversation!
    @conversation = organization.conversations.find_by_external_id(card_id)

    @conversation ||= organization.conversations.create!(
      subject:     subject,
      creator_id:  user.try(:id),
      groups:      [group],
      external_id: card_id,
    )
    @incoming_integration_hook.conversation = @conversation
  end

  def create_message_with_body! body
    @message = conversation.messages.create!(
      creator_id:        user.try(:id),
      date_header:       date_header,
      to_header:         organization.formatted_email_address,
      subject:           subject,
      parent_message:    parent_message,
      from:              from,
      body:              body
      # attachments:       @incoming_integration_hook.attachments.all,
    )
    @incoming_integration_hook.message = @message
  end

  def user
    return @user if @user.present?
    external_auth = threadable.external_authorizations.find_by_unique_id(action['memberCreator']['id'])
    if external_auth.present?
      return @user = threadable.users.find_by_id(external_auth.user_id)
    end

    member = client.find(:member, action['memberCreator']['username'])
    return @user = threadable.users.find_by_email_address(member['email'])
  end

  def subject
    action['data']['card']['name']
  end

  def card_id
    action['data']['card']['id']
  end

  def parent_message
    conversation.messages.latest
  end

  def from
    user.formatted_email_address
  end

  def date_header
    Time.parse(action['date']).rfc2822
  end

end
