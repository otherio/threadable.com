class OrganizationMembersSerializer < UsersSerializer

  def serialize_record member
    super.merge(
      subscribed:              member.subscribed?,
      role:                    member.role,
      confirmed:               member.confirmed?,
    )
  end

end
