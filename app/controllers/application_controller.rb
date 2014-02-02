class ApplicationController < ActionController::Base

  protect_from_forgery

  include AuthenticationConcern
  include RescueFromExceptionsConcern
  include DebugCookie

  before_action :require_user_be_signed_in!

end
