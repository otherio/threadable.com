class CurrentUserSerializer < Serializer

  self.singular_record_name = :user
  self.plural_record_name = :users

  def serialize_record current_user
    {
      id:                      'current',
      user_id:                 current_user.user_id,
      param:                   current_user.to_param,
      name:                    current_user.name,
      email_address:           current_user.email_address.to_s,
      slug:                    current_user.slug,
      avatar_url:              current_user.avatar_url,
      external_authorizations: serialize(:external_authorizations, current_user.external_authorizations.all),
      current_organization_id: current_user.current_organization_id,
      organizations:           serialize(:light_organizations, current_user.organizations.all),
      dismissed_welcome_modal: current_user.dismissed_welcome_modal?,
    }
  end

end
