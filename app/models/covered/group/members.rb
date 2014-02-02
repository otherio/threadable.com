require_dependency 'covered/organization'

class Covered::Group::Members < Covered::Collection

  def initialize group
    @group = group
    @covered = group.covered
  end
  attr_reader :group

  def all
    scope.map{|user_record| Covered::User.new(covered, user_record) }
  end

  def find_by_user_id user_id
    user_record = scope.where(users:{id:user_id}).first or return
    Covered::User.new(covered, user_record)
  end

  def find_by_user_id! user_id
    find_by_user_id(user_id) or
      raise Covered::RecordNotFound, "unable to find group member with id: #{user_id}"
  end

  def add user
    group.group_record.members << user.user_record
  end

  def remove user
    group.group_record.members.delete(user.user_record)
  end

  def include? member
    return false unless member.respond_to?(:user_id)
    !!group.group_record.group_members.where(user_id: member.user_id).exists?
  end

  def inspect
    %(#<#{self.class} organization_id: #{group.organization.id.inspect} group_id: #{group.id.inspect}>)
  end

  private

  def scope
    group.group_record.members.unload
  end

end
