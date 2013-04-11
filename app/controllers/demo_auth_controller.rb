class DemoAuthController < ActionController::Base
  # GET /demo
  def show
    user = User.find_by_name('Alice Neilson')
    sign_in(user)

    redirect_to project_conversations_path(current_user.projects.first)
  end
end
