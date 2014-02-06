class Threadable::Group::Member < Threadable::User

  def initialize group, group_membership_record
    @group, @group_membership_record = group, group_membership_record
    @threadable = group.threadable
    group.id == group_membership_record.group_id or raise ArgumentError
  end
  attr_reader :group, :group_membership_record
  delegate :group_id, :user_id, to: :group_membership_record

  def user_record
    group_membership_record.user
  end

  def organization_record
    group_membership_record.organization
  end

  def gets_no_mail!
    group_membership_record.gets_no_mail!
  end

  def gets_messages!
    group_membership_record.gets_messages!
  end

  def gets_in_summary!
    group_membership_record.gets_in_summary!
  end

  def gets_no_mail?
    group_membership_record.gets_no_mail?
  end

  def gets_messages?
    group_membership_record.gets_messages?
  end

  def gets_in_summary?
    group_membership_record.gets_in_summary?
  end

end
