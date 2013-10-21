class Users::ResetPasswordController < ApplicationController

  def request_link
    email = params.require(:password_recovery).require(:email)
    user = User.with_email(email).first

    case
    when user && user.has_password?
      UserMailer.reset_password(user).deliver!
      render json: {done: "We've emailed you an account recovery link. Please check your email."}
    when user
      UserMailer.reset_password(user).deliver!
      render json: {done: "We've emailed you a link to setup your account. Please check your email."}
    else
      render json: {error: "No account found with that email address"}
    end
  end

  def show
    user = User.where(id: user_id_from_token).first
    if user.nil?
      redirect_to root_url
    else
      sign_in! user
    end
  end

  def reset
    unauthorized! if current_user_id != user_id_from_token
    attributes = params.require(:user).permit(:password, :password_confirmation)
    if current_user.update_attributes(attributes)
      flash[:notice] = 'Your password has been updated'
      redirect_to root_path
    else
      render :show
    end
  end

  private

  def user_id_from_token
    ResetPasswordToken.decrypt(params[:token])
  end

end
