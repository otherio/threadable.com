class HomepageController < ApplicationController

  def show
    render :signed_in if user_signed_in?
  end

end
