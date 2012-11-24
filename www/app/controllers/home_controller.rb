class HomeController < ApplicationController

  def index
    if authenticated?
      debugger;1
      @projects = current_user.projects.find
      render :authenticated
    else
      render :unauthenticated
    end
  end

end
