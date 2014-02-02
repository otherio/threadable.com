class Threadable::Organizations::Create < MethodObject

  def call organizations, attributes
    add_current_user_as_a_member = attributes.key?(:add_current_user_as_a_member) ?
      attributes.delete(:add_current_user_as_a_member) : true

    organization_record = ::Organization.create(attributes)
    organization = Threadable::Organization.new(organizations.threadable, organization_record)
    return organization unless organization_record.persisted?

    if organizations.threadable.current_user && add_current_user_as_a_member
      organization.members.add(user: organizations.threadable.current_user, send_join_notice: false)
    end
    return organization
  end

end
