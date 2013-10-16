module RescueFromExceptionsConcern
  extend ActiveSupport::Concern

  NOT_FOUND_EXCEPTIONS = [
    ::ActionController::RoutingError,
    ::ActionController::UnknownController,
    ::AbstractController::ActionNotFound,
    ::ActiveRecord::RecordNotFound,
  ]


  included do
    unless Rails.application.config.consider_all_requests_local
      rescue_from Exception, with: :rescue_from_exception
    end
  end

  private

  def rescue_from_exception exception
    status = case exception
    when ActiveRecord::RecordNotFound; 404
    else; 500
    end
    respond_to do |format|
      format.html { render template: "errors/error_#{status}", layout: 'layouts/error', status: status }
      format.all { render nothing: true, status: status }
    end
  end

end
