class Threadable::Organization::Ungrouped

  include Let

  def initialize organization
    @organization = organization
  end
  attr_reader :organization
  delegate :threadable, :organization_record, to: :organization

  include Threadable::Conversation::Scopes

  def gets_no_mail!
    organization_membership_record.gets_no_ungrouped_conversation_mail!
  end

  def gets_messages!
    organization_membership_record.gets_ungrouped_conversation_messages!
  end

  def gets_in_summary!
    organization_membership_record.gets_ungrouped_conversations_in_summary!
  end

  def gets_no_mail?
    organization_membership_record.gets_no_ungrouped_conversation_mail?
  end

  def gets_messages?
    organization_membership_record.gets_ungrouped_conversation_messages?
  end

  def gets_in_summary?
    organization_membership_record.gets_ungrouped_conversations_in_summary?
  end

  private

  let :organization_membership_record do
    organization.membership.organization_membership_record
  end

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
