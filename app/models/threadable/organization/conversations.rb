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

  def with_last_message_at time
    conversations_for scope.untrashed.with_last_message_at(time)
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
    if threadable.current_user
      if organization.members.current_member && organization.members.current_member.can?(:read_private, organization.groups)
        organization.organization_record.conversations
      else
        organization.organization_record.conversations.accessible_to_user(threadable.current_user_id)
      end
    else
      organization.organization_record.conversations.in_open_groups
    end
  end

  def muted_scope
    scope.untrashed.muted_by(threadable.current_user_id)
  end

  def not_muted_scope
    scope.untrashed.not_muted_by(threadable.current_user_id)
  end

  def conversation_for conversation_record
    conversation = super
    conversation.organization = organization
    conversation
  end

end
