class HomepageController < ApplicationController

  def show
    if signed_in?
      @projects = current_user.projects.all
      render template: 'projects/index'
    end
  end

end
