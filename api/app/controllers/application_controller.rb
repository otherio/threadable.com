class ApplicationController < ActionController::Base
  protect_from_forgery

  # this is required for devise trackable to work with token auth
  # this is hard to test, so the spec is in projects_controller_spec for now
  before_filter :skip_trackable
  def skip_trackable
    request.env['devise.skip_trackable'] = true
  end
end
