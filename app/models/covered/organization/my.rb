class Covered::Organization::My

  def initialize organization
    @organization = organization
  end
  attr_reader :organization, :covered
  delegate :covered, :organization_record, to: :organization

  include Covered::Conversation::Scopes

  private

  def conversations_scope
    organization_record.conversations.for_user(covered.current_user_id)
  end

  def tasks_scope
    organization_record.tasks.for_user(covered.current_user_id)
  end

end
