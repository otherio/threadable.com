class HomepageController < ApplicationController

  skip_before_action :require_user_be_signed_in!
  before_action :render_client_app_if_signed_in!

  def show
    @sign_up = SignUp.new(params)
    render 'homepage/show', layout: 'new'
    threadable.track('Homepage visited')
  end

  private

  def render_client_app_if_signed_in!
    render 'client_app/show', layout: 'client_app' if signed_in?
  end

end
