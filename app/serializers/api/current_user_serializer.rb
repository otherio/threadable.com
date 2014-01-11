class Api::CurrentUserSerializer < Serializer

  def serialize_record user
    return nil if user.nil?
    json = {
      id:            user.id,
      param:         user.to_param,
      name:          user.name,
      email_address: user.email_address.to_s,
      slug:          user.slug,
      avatar_url:    user.avatar_url,
    }

    json.merge! Api::OrganizationsSerializer[user.organizations.all]

    json
  end

end
