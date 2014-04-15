class ApiAccessTokensController < ApplicationController

  def create
    current_user.regenerate_api_access_token!
    redirect_to profile_path
    flash[:notice] = "Your new API Access Token has been generated."
  end

end
