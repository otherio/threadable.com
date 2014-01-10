class Api::UsersSerializer < Serializer

  def serialize_record user
    {
      id:            user.id,
      param:         user.to_param,
      name:          user.name,
      email_address: user.email_address.to_s,
      slug:          user.slug,
      avatar_url:    user.avatar_url,
      links: {
        organizations: api_organizations_path,
      },
    }
  end

end
