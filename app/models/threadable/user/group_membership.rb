class Threadable::User::GroupMembership < Threadable::Model

  def initialize user, group_membership_record
    @user, @group_membership_record = user, group_membership_record
    @user.id == @group_membership_record.user_id or raise ArgumentError
    @threadable = @user.threadable
  end
  attr_reader :user, :group_membership_record
  delegate :user_id, :group_id, to: :group_membership_record

  def inspect
    %(#<#{self.class} group_id: #{group_id.inspect}, user_id: #{user_id.inspect}>)
  end

end
