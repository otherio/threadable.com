class ApplicationController < ActionController::Base

  protect_from_forgery

  include AuthenticationConcern
  include RescueFromExceptionsConcern

  private

  delegate :render_widget, to: :view_context


end
