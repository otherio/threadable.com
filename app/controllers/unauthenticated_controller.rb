class UnauthenticatedController < ActionController::Base

  protect_from_forgery

  include AuthenticationConcern
  include RescueFromExceptionsConcern
end