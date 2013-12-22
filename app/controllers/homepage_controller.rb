class HomepageController < ApplicationController

  def show
    if signed_in?
      @organizations = current_user.organizations.all
      render template: 'organizations/index'
    else
      redirect_to sign_in_path
    end
  end

end
