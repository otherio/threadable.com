class DemoAuthController < ApplicationController
  # GET /demoauth
  def index
    sign_in! User.with_email_address('amywong.phd@gmail.com').first!
    redirect_to organization_conversations_path(current_user.organizations.find_by_slug!('sfhealth'))
  end
end
