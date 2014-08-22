require 'csv'

class Admin::UsersController < ApplicationController

  layout 'old'

  before_action :require_user_be_admin!

  def index
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

  def merge
    @user = threadable.users.find_by_slug!(params.require(:user_id))
    @destination_user = threadable.users.find_by_id!(params.require(:destination_user_id))

    raise "you cannot merge yourself" if @user.same_user? current_user
    if params[:confirmed]
      @user.merge_into!(@destination_user)
      flash[:success] = "#{@user.name} (user #{@user.id}) was merge into #{@destination_user.name} (user #{@destination_user.id})"
      redirect_to admin_user_path(@destination_user)
    end
  end

  def emails
    send_data(threadable.users.all_email_addresses.map(&:to_csv).join("\n"), filename: 'threadable-emails.csv')
  end

end
