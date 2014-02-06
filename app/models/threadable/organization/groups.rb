require_dependency 'threadable/organization'
require_dependency 'threadable/organization/group'

class Threadable::Organization::Groups < Threadable::Groups

  def initialize organization
    @organization = organization
    @threadable = organization.threadable
  end
  attr_reader :organization

  def create attributes={}
    Create.call(self, attributes);
  end

  def create! attributes={}
    group = create(attributes)
    group.persisted? or raise Threadable::RecordInvalid, "Group invalid: #{group.errors.full_messages.to_sentence}"
    group
  end

  def inspect
    %(#<#{self.class} organization_id: #{organization.id.inspect}>)
  end

  private

  def scope
    organization.organization_record.groups
  end

  def group_for group_record
    Threadable::Organization::Group.new(organization, group_record) if group_record
  end

  def groups_for group_records
    group_records.map{|group_record| group_for group_record }
  end

end

require 'threadable/organization/groups/create'
