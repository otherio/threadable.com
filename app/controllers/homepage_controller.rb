class HomepageController < ApplicationController

  skip_before_action :require_user_be_signed_in!

  def show
    if signed_in?
      render 'client_app/show', layout: 'client_app'
    else
      redirect_to sign_in_path
      # render 'homepage/show'
    end
  end

end
