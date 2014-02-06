class Threadable::Organization::Ungrouped

  include Let

  def initialize organization
    @organization = organization
  end
  attr_reader :organization
  delegate :threadable, :organization_record, to: :organization

  include Threadable::Conversation::Scopes

  private

  def conversations_scope
    ungrouped organization_record.conversations
  end

  def tasks_scope
    ungrouped organization_record.tasks
  end

  def ungrouped scope
    scope.
      joins('LEFT JOIN conversation_groups ON conversation_groups.conversation_id = conversations.id').
      where(conversation_groups:{conversation_id:nil})
  end


end
