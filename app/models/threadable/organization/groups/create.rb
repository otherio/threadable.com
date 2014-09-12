class Threadable::Organization::Groups::Create < MethodObject

  def call groups, attributes
    organization = groups.organization

    if attributes[:private].present? && attributes[:private]  #present and any true value
      organization.members.current_member.can?(:make_private, groups) or raise Threadable::AuthorizationError, 'You do not have permission to make private groups for this organization'
    end

    attributes[:organization] = organization.organization_record
    attributes[:subject_tag] ||= "#{organization.subject_tag}+#{attributes[:name]}"
    group = nil
    Threadable.transaction do
      group_record = ::Group.create(attributes)
      group = Threadable::Group.new(groups.threadable, group_record)
      if group.auto_join?
        organization.members.all.each do |member|
          group.members.add member
        end
      end
    end
    return group
  end

end
