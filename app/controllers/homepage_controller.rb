class HomepageController < ApplicationController

  skip_before_action :require_user_be_signed_in!
  before_action :render_client_app_if_signed_in!

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

  def render_client_app_if_signed_in!
    return if ['/frontpage', '/pro', '/pricing'].include?(request.path)
    if signed_in?
      @realtime_token = UpdateRealtimeToken.call(threadable, session)
      @realtime_url = Rails.configuration.realtime[:url]
      render 'client_app/show', layout: 'client_app'
    end
  end

end
