require_dependency 'covered/group'
require_dependency 'covered/organization'

class Covered::Group::Tasks < Covered::Organization::Tasks

  def initialize group
    @group = group
    super group.organization
  end
  attr_reader :group

  def create attributes={}
    super attributes.merge(group: group)
  end

  def inspect
    %(#<#{self.class} organization_id: #{organization.id.inspect} group_id: #{group.id.inspect}>)
  end

  private

  def scope
    group.group_record.tasks.unload
  end

end
