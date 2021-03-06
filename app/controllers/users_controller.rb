class UsersController < ApplicationController

  before_filter :require_user_not_be_signed_in!, only: [:create, :new]
  before_filter :require_user_be_signed_in!,     only: [:show, :edit, :update]
  before_filter :require_user_be_current_user!,  only: [:edit, :update]

  def index
    not_found!
  end

  def show
    @user = threadable.users.find_by_slug!(params[:id])
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
    @user_params or begin
      @user_params = params.require(:user).permit(:name, :email_address, :password, :password_confirmation).symbolize_keys
      @user_params[:email_address].try(:strip_non_ascii!)
    end
    @user_params
  end

  def require_user_be_current_user!
    not_found! if current_user.to_param != params[:id]
    @user = current_user
  end

end
