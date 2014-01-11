class Api::CurrentUserSerializer

  def self.[] current_user
    {
      user: {
        id:            'current',
        param:         current_user.to_param,
        name:          current_user.name,
        email_address: current_user.email_address.to_s,
        slug:          current_user.slug,
        avatar_url:    current_user.avatar_url,
      }
    }
  end

end
