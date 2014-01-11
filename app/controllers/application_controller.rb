class ApplicationController < UnauthenticatedController

  # before_action do
  #   return unless params["controller"] == "application" && params["action"] == "show"
  #   if request.xhr? || !request.get? || request.accepts.exclude?(:html)
  #       raise ActionController::RoutingError.new('Not Found')
  #     else
  #       return # pass through
  #     end
  #   end
  #   render 'application/show', layout: false
  # end

  before_action :require_user_be_signed_in!

end
