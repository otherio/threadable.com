class Threadable::Organization::My

  def initialize organization
    @organization = organization
  end
  attr_reader :organization, :threadable
  delegate :threadable, :organization_record, to: :organization

  include Threadable::Conversation::Scopes

  private

  def conversations_scope
    organization_record.conversations.untrashed.for_user(threadable.current_user.id).grouped
  end

  def tasks_scope
    organization_record.tasks.untrashed.for_user(threadable.current_user.id).grouped
  end

end
