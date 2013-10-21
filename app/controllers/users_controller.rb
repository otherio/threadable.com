class UsersController < ApplicationController

  before_filter :require_user_not_be_signed_in!, only: [:create, :new]
  before_filter :require_user_be_signed_in!,     only: [:show, :edit, :update]

  def index
    unauthorized!
  end

  def create
    @user = UserCreator.call(user_params)
    if @user.errors.present?
      render :new
      return
    end
    UserMailer.sign_up_confirmation(@user).deliver!
  end

  def new
    if signup_enabled?
      @user = User.new
    else
      redirect_to root_url
    end
  end

  def edit
    unauthorized! if current_user != user
  end

  def show
    user
  end

  def update
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
    @user ||= User.where(slug: params[:id]).first!
  end

end
