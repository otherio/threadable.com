class CurrentUserSerializer < Serializer

  self.singular_record_name = :user
  self.plural_record_name = :users

  def serialize_record current_user
    if current_user
      {
        id:            'current',
        user_id:       current_user.user_id,
        param:         current_user.to_param,
        name:          current_user.name,
        email_address: current_user.email_address.to_s,
        slug:          current_user.slug,
        avatar_url:    current_user.avatar_url,
        organizations: serialize(:organizations, current_user.organizations.all),
      }
    else
      {
        id:            'current',
        user_id:       nil,
        param:         nil,
        name:          nil,
        email_address: nil,
        slug:          nil,
        avatar_url:    nil,
        organizations: [],
      }
    end
  end

end
