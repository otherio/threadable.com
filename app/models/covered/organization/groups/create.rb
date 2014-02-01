class Covered::Organization::Groups::Create < MethodObject

  def call groups, attributes
    organization = groups.organization
    attributes[:organization] = organization.organization_record
    attributes[:subject_tag] ||= "#{organization.subject_tag}+#{attributes[:name]}"
    group_record = ::Group.create(attributes)
    group = Covered::Group.new(groups.covered, group_record)
    return group
  end

end
