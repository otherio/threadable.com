class HomepageController < ApplicationController

  skip_before_action :require_user_be_signed_in!
  before_action :redirect_to_client_app_if_signed_in!

  def show
    @sign_up = SignUp.new(params)
    @on_homepage = true
    render 'homepage/show', layout: 'new'
  end

  def pricing
    @sign_up = SignUp.new(params)
    render 'homepage/pricing', layout: 'new'
  end

  private

  def redirect_to_client_app_if_signed_in!
    return if ['/frontpage', '/pro', '/pricing'].include?(request.path)
    if signed_in?
      current_organization = current_user.current_organization || current_user.organizations.all.first
      redirect_to conversations_path(current_organization, 'my')
    end
  end

end
