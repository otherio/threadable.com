class Threadable::Groups < Threadable::Collection

  def all
    groups_for scope
  end

  def my
    groups_for scope.joins(:group_members).where(group_memberships:{ user_id: threadable.current_user_id })
  end

  def include? group
    !!scope.where(id: group.group_id).exists?
  end

  def empty?
    count == 0
  end

  private

  def scope
    ::Group.all
  end

  def group_for group_record
    Threadable::Group.new(threadable, group_record) if group_record
  end

  def groups_for group_records
    group_records.map{ |group_record| group_for group_record }
  end

end
