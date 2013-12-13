module RescueFromExceptionsConcern
  extend ActiveSupport::Concern

  included do
    rescue_from Exception, with: :rescue_from_exception
  end

  private

  NOT_LOGGED_IN_EXCEPTION = [
    Covered::AuthenticationError,
    Covered::CurrentUserNotFound,
  ].freeze

  NOT_FOUND_EXCEPTION = [
    ActionController::RoutingError,
    ActionController::UnknownController,
    AbstractController::ActionNotFound,
    ActiveRecord::RecordNotFound,
    Covered::RecordNotFound,
    Covered::AuthorizationError,
  ].freeze

  def rescue_from_exception exception
    logger.debug "rescuing from exception: #{exception.class}(#{exception.message.inspect})"
    case exception
    when *NOT_FOUND_EXCEPTION
      render_error_page 404
    when *NOT_LOGGED_IN_EXCEPTION
      sign_out!
      redirect_to sign_in_path(r: request.original_url)
    else
      covered.report_exception! exception
      raise exception if Rails.application.config.consider_all_requests_local
      render_error_page 500
    end
  end

  def render_error_page status
    respond_to do |format|
      format.html { render template: "errors/error_#{status}", layout: 'layouts/error', status: status }
      format.all { render nothing: true, status: status }
    end
  end

end
