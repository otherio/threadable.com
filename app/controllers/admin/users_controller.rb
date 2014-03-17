class Admin::UsersController < ApplicationController

  layout 'old'

  before_action :require_user_be_admin!

  def index
    @page_size = 20
    @page = params[:page].to_i
    @query = params[:q].to_s
    @users = threadable.users.search(@query, page: @page)
  end

  def show
    redirect_to admin_edit_user_path
  end

  def edit
    @user = threadable.users.find_by_slug!(params[:user_id])
  end

  # PATCH /admin/users/:user_id
  def update
    @user = threadable.users.find_by_slug!(params[:user_id])
    @user_params = params[:user].permit(
      :name,
      :slug,
      :password,
      :password_confirmation,
      :munge_reply_to,
      :email_addresses_as_string
    )
    email_addresses_as_string = @user_params.delete(:email_addresses_as_string)
    if @user.update(@user_params)
      flash[:success] = "update of #{@user.formatted_email_address} was successful."
      redirect_to admin_users_path
    else
      flash.now[:danger] = "update of #{@user.formatted_email_address} was unsuccessful."
      render :edit
    end
  end

end
