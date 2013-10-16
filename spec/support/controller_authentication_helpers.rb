module ControllerAuthenticationHelpers

  def sign_in_as user
    cookies[:remember_me] = RememberMeToken.encrypt user.id
  end

end
