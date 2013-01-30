class HomepageController < ApplicationController

  def show
    if user_signed_in?
      @projects = current_user.projects
      render template: 'projects/index'
    end
  end

end
