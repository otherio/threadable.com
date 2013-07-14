class RegistrationsController < Devise::RegistrationsController

  # POST /resource
  def create
    build_resource params.require(:user).permit(:name, :email)

    if resource.save
      expire_session_data_after_sign_in!
      respond_with resource, :location => thanks_for_signing_up_path
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  def thanks
  end

  def new
    return super if Rails.configuration.login_enabled
    redirect_to "http://signup.other.io"
  end

end
