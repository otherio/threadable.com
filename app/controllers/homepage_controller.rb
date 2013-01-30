class HomepageController < ApplicationController

  def show
    flash[:message] = 'hello'
    flash[:error] = 'hello'
    flash[:notice] = 'hello'
    render :signed_in if user_signed_in?
  end

end
