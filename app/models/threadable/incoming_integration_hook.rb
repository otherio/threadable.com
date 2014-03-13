class Threadable::IncomingIntegrationHook < Threadable::Model

  self.model_name = ::IncomingIntegrationHook.model_name

  def initialize threadable, incoming_integration_hook_record
    @threadable, @incoming_integration_hook_record = threadable, incoming_integration_hook_record
  end
  attr_reader :threadable, :incoming_integration_hook_record

  delegate *%w{
    id
    params
    processed?
    created_at
    external_conversation_id
    external_message_id
    errors
    persisted?
    save!
  }, to: :incoming_integration_hook_record

  def process!
    # binding.pry
  end

end
