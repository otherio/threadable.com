class Admin::UsersController < ApplicationController

  layout 'old'

  before_action :require_user_be_admin!

  def edit
    @user = threadable.users.find_by_id(params[:user_id])
    @organization = threadable.organizations.find_by_slug! params[:organization]
  end

  # PATCH /admin/users/:user_id
  def update
    user_id = params.require(:user_id)
    user_params = params.permit(user: :munge_reply_to)[:user].symbolize_keys
    user = threadable.users.find_by_id! user_id.to_i
    if user.update(user_params)
      flash[:notice] = "update of #{user.formatted_email_address} was successful."
    else
      flash[:alert] = "update of #{user.formatted_email_address} was unsuccessful."
    end
    redirect_to admin_edit_organization_path(params[:user][:organization])
  end

  private

end
