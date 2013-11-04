class HomepageController < ApplicationController

  def show
    if signed_in?
      @projects = covered.projects.all
      render template: 'projects/index'
    end
  end

end
