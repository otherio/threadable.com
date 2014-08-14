class GroupMembersSerializer < UsersSerializer

  def serialize_record member
    super.merge(
      delivery_method: member.delivery_method,
    )
  end

end
