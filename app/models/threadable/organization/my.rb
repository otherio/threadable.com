class Threadable::Organization::My

  def initialize organization
    @organization = organization
  end
  attr_reader :organization, :threadable
  delegate :threadable, :organization_record, to: :organization

  include Threadable::Conversation::Scopes

  private

  def conversations_scope
    if organization.members.current_member.can?(:read_private, organization.groups)
      organization_record.conversations.untrashed.for_user_with_private(threadable.current_user_id)
    else
      organization_record.conversations.untrashed.for_user(threadable.current_user_id)
    end
  end

  def tasks_scope
    if organization.members.current_member.can?(:read_private, organization.groups)
      organization_record.tasks.untrashed.for_user_with_private(threadable.current_user_id)
    else
      organization_record.tasks.untrashed.for_user(threadable.current_user_id)
    end
  end

end
