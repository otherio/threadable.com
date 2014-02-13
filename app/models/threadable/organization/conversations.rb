require_dependency 'threadable/organization'

class Threadable::Organization::Conversations < Threadable::Conversations

  def initialize organization
    @organization = organization
    @threadable = organization.threadable
  end
  attr_reader :organization

  def muted
    return [] if threadable.current_user_id.nil?
    conversations_for muted_scope
  end

  def not_muted
    return [] if threadable.current_user_id.nil?
    conversations_for not_muted_scope
  end

  def muted_with_participants
    return [] if threadable.current_user_id.nil?
    conversations_for muted_scope.includes(:participants)
  end

  def not_muted_with_participants
    return [] if threadable.current_user_id.nil?
    conversations_for not_muted_scope.includes(:participants)
  end

  def ungrouped
    conversations_for ungrouped_scope
  end

  def ungrouped_with_last_message_at time
    conversations_for ungrouped_scope.with_last_message_at(time)
  end

  def with_last_message_at time
    conversations_for scope.with_last_message_at(time)
  end

  def build attributes={}
    conversation_for scope.build(attributes)
  end
  alias_method :new, :build

  def create attributes={}
    super attributes.merge(organization: organization)
  end

  def inspect
    %(#<#{self.class} organization_id: #{organization.id.inspect}>)
  end

  private

  def scope
    organization.organization_record.conversations.unload
  end

  def muted_scope
    scope.muted_by(threadable.current_user_id)
  end

  def not_muted_scope
    scope.not_muted_by(threadable.current_user_id)
  end

  def ungrouped_scope
    scope.
      joins("LEFT JOIN conversation_groups ON conversation_groups.conversation_id = conversations.id and conversation_groups.active = 't'").
      where(conversation_groups:{conversation_id:nil})
  end

  def conversation_for conversation_record
    conversation = super
    conversation.organization = organization
    conversation
  end

end
