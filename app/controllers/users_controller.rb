class UsersController < ApplicationController

  before_filter :require_user_not_be_signed_in!, only: [:create, :new]
  before_filter :require_user_be_signed_in!,     only: [:show, :edit, :update]
  before_filter :require_user_be_current_user!,  only: [:edit, :update]

  def index
    unauthorized!
  end

  def create
    @user = covered.sign_up(user_params)
    if @user.persisted?
      covered.emails.send_email_async(:sign_up_confirmation, @user.id)
      render :create
    else
      render :new
    end
  end

  def new
    unauthorized! unless signup_enabled?
    @user = covered.users.new
  end

  def show
    @user = covered.users.find_by_slug!(params[:id])
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to user_url(@user)
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email_address, :password, :password_confirmation).symbolize_keys
  end

  def require_user_be_current_user!
    unauthorized! if current_user.to_param != params[:id]
    @user = current_user
  end

end
