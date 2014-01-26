class FrontendController < ApplicationController

  skip_before_action :require_user_be_signed_in!

  def show
    if request.xhr? || !request.get? || request.accepts.exclude?(:html)
      raise ActionController::RoutingError.new('Not Found')
    end
  end

end
