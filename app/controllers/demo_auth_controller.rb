class DemoAuthController < ApplicationController
  # GET /demo
  def index
    user = User.where(name: 'Alice Neilson').first!
    sign_in! user

    redirect_to project_conversations_path(current_user.projects.first)
  end
end
