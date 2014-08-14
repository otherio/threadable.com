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

  def scope_without_groups
    OrganizationMembership.
      includes(:user).
      distinct.
      who_get_email.
      for_organization(conversation.organization_id).
      who_have_not_muted(conversation.id)
  end

  def scope
    groups = conversation.groups.all
    scope_without_groups.in_groups_with_each_message_including_followers(conversation.id, groups.map(&:id), false)
  end

end
