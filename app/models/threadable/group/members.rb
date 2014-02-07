require_dependency 'threadable/group/member'

class Threadable::Group::Members < Threadable::Collection

  def initialize group
    @group = group
    @threadable = group.threadable
  end
  attr_reader :group

  def all
    group_members_for scope
  end

  def find_by_user_id user_id
    group_member_for (scope.where(user_id: user_id).first or return)
  end

  def find_by_user_id! user_id
    find_by_user_id(user_id) or
      raise Threadable::RecordNotFound, "unable to find group member with id: #{user_id}"
  end

  def me
    raise Threadable::AuthorizationError unless current_user
    find_by_user_id! current_user.id
  end

  def add user
    group.group_record.members += [user.user_record]
  end

  def remove user
    group.group_record.members.delete(user.user_record)
  end

  def include? member
    !!group.group_record.group_memberships.where(user_id: member.user_id).exists?
  end

  def inspect
    %(#<#{self.class} organization_id: #{group.organization.id.inspect} group_id: #{group.id.inspect}>)
  end

  private

  def group_member_for group_membership_records
    Threadable::Group::Member.new(group, group_membership_records)
  end

  def group_members_for group_membership_records
    group_membership_records.map do |group_membership_records|
      group_member_for group_membership_records
    end
  end

  def scope
    group.group_record.group_memberships.unload
  end

end
