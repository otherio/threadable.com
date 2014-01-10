class ApplicationController < ActionController::Base

  protect_from_forgery

  include AuthenticationConcern
  include RescueFromExceptionsConcern

  before_action do
    if request.xhr? || !request.get? || request.accepts.exclude?(:html)
      if params["controller"] == "application" && params["action"] == "show"
        raise ActionController::RoutingError.new('Not Found')
      else
        return # pass through
      end
    end
    render 'application/show'
  end

  before_action :require_user_be_signed_in!

end
