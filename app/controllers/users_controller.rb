class UsersController < ApplicationController

  before_filter :require_user_not_be_signed_in!, only: [:create, :new]
  before_filter :require_user_be_signed_in!,     only: [:show, :edit, :update]

  def index
    unauthorized!
  end

  def create
    @user = covered.sign_up(user_params)
    if @user.errors.present?
      render :new
    else
      covered.emails.send_email_async(:sign_up_confirmation, @user.id)
      render :create
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
    unauthorized! if current_user.id != user.id
  end

  def update
    unauthorized! if current_user.id != user.id
    if current_user.update!(user_params)
      redirect_to root_path
    else
      render :edit
    end
  end

  def destroy

  end

  private

  def user_params
    params.require(:user).permit(:name, :email_address, :password, :password_confirmation).symbolize_keys
  end

  def user
    @user ||= covered.users.find_by_slug!(params[:id])
  end

end
