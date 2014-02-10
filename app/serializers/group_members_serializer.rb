class GroupMembersSerializer < UsersSerializer

  def serialize_record member
    super.merge(
      in_summary: false,
    )
  end

end
