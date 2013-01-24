class SessionsController < ApplicationController

  before_filter :authenticate_user!

  def new
    @session = Session.new
  end

  def create
    @session = Session.new(params[:session])
    if @session.valid?
      flash[:message] = "Welcome back #{@session.user.name}"
      redirect_to root_url
    else
      flash[:error] = @session.errors.full_messages
      render :new
    end
  end

  def destroy
    session.destroy
  end

end
