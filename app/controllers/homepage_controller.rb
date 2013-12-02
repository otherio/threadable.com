class HomepageController < ApplicationController

  def show
    if signed_in?
      @projects = current_user.projects.all
      render template: 'projects/index'
    else
      redirect_to sign_in_path
    end
  end

end
