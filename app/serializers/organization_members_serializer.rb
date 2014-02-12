class OrganizationMembersSerializer < UsersSerializer

  def serialize_record member
    super.merge(
      subscribed:              member.subscribed?,
      role:                    member.role,
      ungrouped_mail_delivery: member.ungrouped_mail_delivery,
    )
  end

end
