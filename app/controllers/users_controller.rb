class UsersController < ApplicationController

  before_filter :require_user_not_be_signed_in!, only: [:create, :new]
  before_filter :require_user_be_signed_in!,     only: [:show, :edit, :update]

  def index
    unauthorized!
  end

  def create
    @user = covered.users.create(user_params)
    if @user.errors.present?
      render :new
    else
      covered.send_email(:sign_up_confirmation, recipient_id: user.id)
    end
  end

  def new
    if signup_enabled?
      @user = covered.users.new
    else
      redirect_to root_url
    end
  end

  def show
    user
  end

  def edit
    unauthorized! if current_user != user
  end

  def update
    unauthorized! if current_user != user
    if user.update_attributes(user_params)
      redirect_to root_path
    else
      render :edit
    end
  end

  def destroy

  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def user
    @user ||= covered.users.get(slug: params[:id])
  end

end
