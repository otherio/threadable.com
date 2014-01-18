class Covered::Groups < Covered::Collection

  def all
    groups_for scope
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
    Covered::Group.new(covered, group_record) if group_record
  end

  def groups_for group_records
    group_records.map{ |group_record| group_for group_record }
  end

end
