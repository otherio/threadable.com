class DemoAuthController < ApplicationController
  # GET /demo
  def index
    sign_in! User.with_email('amywong.phd@gmail.com').first!
    redirect_to project_conversations_path(current_user.projects.first)
  end
end
