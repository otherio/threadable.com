class Covered::Organization::Groups::Create < MethodObject

  def call groups, attributes
    organization = groups.organization
    attributes[:organization] = organization.organization_record
    attributes[:subject_tag] ||= "#{organization.subject_tag}+#{attributes[:name]}"
    group = nil
    Covered.transaction do
      group_record = ::Group.create(attributes)
      group = Covered::Group.new(groups.covered, group_record)
      if group.auto_join
        organization.members.all.each do |member|
          group.members.add member
        end
      end
    end
    return group
  end

end
