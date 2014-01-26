class AdminController < ApplicationController

  layout 'old'

  before_action :require_user_be_admin!

  def show
  end

end
