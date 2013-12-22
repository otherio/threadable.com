class Covered::Organizations::Create < MethodObject

  def call organizations, attributes
    add_current_user_as_a_member = attributes.key?(:add_current_user_as_a_member) ?
      attributes.delete(:add_current_user_as_a_member) : true

    organization_record = ::Organization.create(attributes)
    organization = Covered::Organization.new(organizations.covered, organization_record)
    return organization unless organization_record.persisted?

    if organizations.covered.current_user && add_current_user_as_a_member
      organization.members.add(user: organizations.covered.current_user, send_join_notice: false)
    end
    return organization
  end

end
