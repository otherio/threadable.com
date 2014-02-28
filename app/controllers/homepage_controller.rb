class HomepageController < ApplicationController

  skip_before_action :require_user_be_signed_in!
  before_action :redirect_to_client_app_if_signed_in!

  def show
  end

  private

  def redirect_to_client_app_if_signed_in!
    render 'client_app/show', layout: 'client_app' if signed_in?
  end

end
