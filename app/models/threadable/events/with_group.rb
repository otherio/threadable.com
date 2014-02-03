module Threadable::Events::WithGroup

  def group_id
    content[:group_id]
  end

  def group_id= group_id
    content[:group_id] = group_id
  end

  def group
    @group ||= organization.groups.find_by_id!(group_id) if group_id
  end

  def group= group
    @group = group
    self.group_id = group.id
  end

end

