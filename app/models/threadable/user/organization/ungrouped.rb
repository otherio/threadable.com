class Threadable::User::Organization::Ungrouped < Threadable::Organization::Ungrouped

  def initialize organization
    super
    @user = organization.user
  end
  attr_reader :user

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

end
