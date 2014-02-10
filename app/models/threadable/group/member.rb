class Threadable::Group::Member < Threadable::User

  def initialize group, group_membership_record
    @group, @group_membership_record = group, group_membership_record
    group.id == group_membership_record.group_id or raise ArgumentError
    @threadable = group.threadable
  end
  attr_reader :group, :group_membership_record
  delegate :group_id, :user_id, to: :group_membership_record
  delegate :group_record, to: :group

  def user_record
    group_membership_record.user
  end

  delegate *%w{
    id
    name
    avatar_url
    to_param
  }, to: :user_record

  # delegate *%w{

  # }, to: :group_membership_record

  def group_membership_id
    group_membership_record.id
  end

  def user
    @user ||= Threadable::User.new(threadable, user_record)
  end

  def reload
    group_membership_record.reload
    self
  end

  def gets_in_summary?
    !!group_membership_record.summary
  end

  def gets_every_message?
    !gets_in_summary?
  end

  def gets_in_summary!
    return if gets_in_summary?
    group_membership_record.update_attribute(:summary, true)
  end

  def gets_every_message!
    return if !gets_in_summary?
    group_membership_record.update_attribute(:summary, false)
  end

  def == other
    self.class === other && self.user_id == other.user_id && self.group_id == other.group_id
  end

  def inspect
    %(#<#{self.class} group_id: #{group_id.inspect}, user_id: #{user_id.inspect}>)
  end

end
