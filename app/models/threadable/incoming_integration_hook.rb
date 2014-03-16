class Threadable::IncomingIntegrationHook < Threadable::Model

  self.model_name = ::IncomingIntegrationHook.model_name

  def initialize threadable, incoming_integration_hook_record
    @threadable, @incoming_integration_hook_record = threadable, incoming_integration_hook_record
  end
  attr_reader :threadable, :incoming_integration_hook_record

  delegate *%w{
    id
    params
    provider
    processed?
    created_at
    external_conversation_id
    external_message_id
    errors
    persisted?
    save!
  }, to: :incoming_integration_hook_record

  def process!
    if provider == 'trello'
      Threadable::Integrations::TrelloProcessor.call(self)
      incoming_integration_hook_record.update_attribute(:processed, true)
    end
  end



  # def organization= organization
  #   if organization.try(:organization_record).present?
  #     @organization = organization
  #     incoming_email_record.organization = organization.organization_record
  #   else
  #     @organization = incoming_email_record.organization = nil
  #   end
  # end

  def organization
    return unless incoming_integration_hook_record.organization
    @organization ||= Threadable::Organization.new(threadable, incoming_integration_hook_record.organization)
  end

  # def groups= groups
  #   @groups = groups.compact
  #   incoming_integration_hook_record.groups = @groups.map(&:group_record)
  # end

  def group
    return unless incoming_integration_hook_record.group
    @group ||= Threadable::Group.new(threadable, incoming_integration_hook_record.group)
  end

  def conversation= conversation
    @conversation = conversation
    incoming_integration_hook_record.conversation = conversation.conversation_record
  end

  def message= message
    @message = message
    incoming_integration_hook_record.message = message.message_record
  end


end
