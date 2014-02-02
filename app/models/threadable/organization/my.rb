class Threadable::Organization::My

  def initialize organization
    @organization = organization
  end
  attr_reader :organization, :threadable
  delegate :threadable, :organization_record, to: :organization

  include Threadable::Conversation::Scopes

  private

  def conversations_scope
    organization_record.conversations.for_user(threadable.current_user_id)
  end

  def tasks_scope
    organization_record.tasks.for_user(threadable.current_user_id)
  end

end