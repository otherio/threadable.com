class MembersSerializer < Serializer

  def serialize_record member
    {
      id:            member.id,
      user_id:       member.user_id,
      param:         member.to_param,
      name:          member.name,
      email_address: member.email_address.to_s,
      slug:          member.slug,
      avatar_url:    member.avatar_url,
    }
  end

end
