class GroupMembersSerializer < UsersSerializer

  def serialize_record member
    super.merge(
      gets_in_summary: member.gets_in_summary?,
    )
  end

end
