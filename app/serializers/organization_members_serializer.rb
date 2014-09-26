class OrganizationMembersSerializer < UsersSerializer

  def serialize_record member
    @current_member = member.organization.members.try(:current_member)

    super.merge(
      subscribed:              member.subscribed?,
      role:                    member.role,
      confirmed:               member.confirmed?,

      can_change_delivery: can?(:change_delivery_for, member),
    )
  end

end
