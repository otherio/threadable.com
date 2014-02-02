class UsersSerializer < Serializer

  def serialize_record user
    {
      id:            user.id,
      user_id:       user.user_id,
      param:         user.to_param,
      name:          user.name,
      email_address: user.email_address.to_s,
      slug:          user.slug,
      avatar_url:    user.avatar_url,
    }
  end

end
