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

  delegate *%w{
    gets_in_summary?
    gets_in_summary!
    gets_each_message?
    gets_each_message!
    gets_first_message?
    gets_first_message!
    delivery_method
  }, to: :group_membership_record

  def group_membership_id
    group_membership_record.id
  end

  def user
    @user ||= Threadable::User.new(threadable, user_record)
  end

  def delivery_method= delivery_method
    group_membership_record.update_attribute(:delivery_method, delivery_method)
  end

  def reload
    group_membership_record.reload
    self
  end

  def == other
    self.class === other && self.user_id == other.user_id && self.group_id == other.group_id
  end

  def inspect
    %(#<#{self.class} group_id: #{group_id.inspect}, user_id: #{user_id.inspect}>)
  end

end
