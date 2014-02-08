class OrganizationMembersSerializer < UsersSerializer

  def serialize_record member
    super.merge(
      is_subscribed: member.subscribed?,
    )
  end


end
