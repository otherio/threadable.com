class AdminController < ApplicationController

  before_filter :require_user_be_admin!

  def show
  end

end
