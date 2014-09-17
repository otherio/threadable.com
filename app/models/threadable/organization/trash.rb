class Threadable::Organization::Trash

  def initialize organization
    @organization = organization
  end
  attr_reader :organization, :threadable
  delegate :threadable, :organization_record, to: :organization

  include Threadable::Conversation::Scopes

  private

  def conversations_scope
    if organization.members.current_member && organization.members.current_member.can?(:read_private, organization.groups)
      organization_record.conversations.trashed
    else
      organization_record.conversations.accessible_to_user(threadable.current_user_id).trashed
    end
  end

  def tasks_scope
    if organization.members.current_member && organization.members.current_member.can?(:read_private, organization.groups)
      organization_record.tasks.trashed
    else
      organization_record.tasks.accessible_to_user(threadable.current_user_id).trashed
    end
  end

end
