class Threadable::Organization::My

  def initialize organization
    @organization = organization
  end
  attr_reader :organization, :threadable
  delegate :threadable, :organization_record, to: :organization

  include Threadable::Conversation::Scopes

  private

  def conversations_scope
    scope_ungrouped organization_record.conversations.for_user(threadable.current_user.id)
  end

  def tasks_scope
    scope_ungrouped organization_record.tasks.for_user(threadable.current_user.id)
  end

  def scope_ungrouped scope
    return scope.grouped unless organization.members.current_member.gets_each_ungrouped_message?
    scope
  end

end
