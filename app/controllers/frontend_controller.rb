class FrontendController < UnauthenticatedController

  layout false

  def show
    if request.xhr? || !request.get? || request.accepts.exclude?(:html)
      raise ActionController::RoutingError.new('Not Found')
    end
  end

end
