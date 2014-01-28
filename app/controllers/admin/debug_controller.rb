class Admin::DebugController < ApplicationController

  before_action :require_user_be_admin!

  def show
  end

  def enable
    enable_debug!
    redirect_to admin_debug_url
  end

  def disable
    disable_debug!
    redirect_to admin_debug_url
  end

end
