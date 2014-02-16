require_dependency 'threadable/conversation'

class Threadable::Conversation::Recipients

  def initialize conversation
    @conversation = conversation
  end
  attr_reader :conversation
  delegate :threadable, to: :conversation

  def all
    organization_members_for scope
  end

  def include? user
    !!scope.where(user_id: user.user_id).exists?
  end

  def inspect
    %(#<#{self.class} conversation_id: #{conversation.id.inspect}>)
  end

  private

  def organization_member_for organization_membership_record
    Threadable::Organization::Member.new(conversation.organization, organization_membership_record)
  end

  def organization_members_for organization_membership_records
    organization_membership_records.map do |organization_membership_record|
      organization_member_for organization_membership_record
    end
  end

  def scope
    recipients = OrganizationMembership.
      includes(:user).
      who_get_email.
      for_organization(conversation.organization_id).
      who_have_not_muted(conversation.id)

    groups = conversation.groups.all

    if groups.present?
      recipients = recipients.in_groups_without_summary(groups.map(&:id))
    else
      recipients = recipients.who_get_ungrouped
    end

    recipients
  end

end
