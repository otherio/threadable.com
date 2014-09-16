class Threadable::Organization::Trash

  def initialize organization
    @organization = organization
  end
  attr_reader :organization, :threadable
  delegate :threadable, :organization_record, to: :organization

  include Threadable::Conversation::Scopes

  private

  def conversations_scope
    organization_record.conversations.accessible_to_user(threadable.current_user_id).trashed
  end

  def tasks_scope
    organization_record.tasks.accessible_to_user(threadable.current_user_id).trashed
  end

end
