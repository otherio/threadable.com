class GroupMembersSerializer < UsersSerializer

  def serialize_record member
    @current_member = member.group.organization.members.try(:current_member)

    super.merge(
      delivery_method: member.delivery_method,

      can_change_delivery: can?(:change_delivery_for, member),
    )
  end

end
