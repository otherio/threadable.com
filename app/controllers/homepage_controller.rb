class HomepageController < ApplicationController

  def show
    if user_signed_in?
      @projects = current_user.projects
      render template: 'projects/index'
    else
      redirect_to 'http://signup.other.io', status: :temporary_redirect
    end
  end

end
