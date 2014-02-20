module RescueFromExceptionsConcern
  extend ActiveSupport::Concern

  included do
    rescue_from Exception, with: :rescue_from_exception
  end

  private

  UNAUTHORIZED_EXCEPTIONS = [
    Threadable::AuthorizationError,
    Threadable::AuthenticationError,
    Threadable::CurrentUserNotFound,
  ].freeze

  NOT_ACCEPTABLE_EXCEPTIONS = [
    ActionController::UnknownFormat,
    ActionController::ParameterMissing,
  ].freeze

  NOT_FOUND_EXCEPTIONS = [
    ActionController::RoutingError,
    ActionController::UnknownController,
    AbstractController::ActionNotFound,
    ActiveRecord::RecordNotFound,
    Threadable::RecordNotFound,
  ].freeze

  def rescue_from_exception exception
    raise exception if debug_enabled?
    logger.debug "rescuing from exception: #{exception.class}(#{exception.message.inspect})"

    sign_out! if Threadable::CurrentUserNotFound === exception

    raise exception if Rails.env.test? && exception.class.name =~ /RSpec/

    case exception
    when *UNAUTHORIZED_EXCEPTIONS
      report_exception! exception
      render_error exception, :unauthorized,   'Unauthorized'
    when *NOT_ACCEPTABLE_EXCEPTIONS
      render_error exception, :not_acceptable, 'Not Acceptable'
    when *NOT_FOUND_EXCEPTIONS
      render_error exception, :not_found,      'Not Found'
    else
      report_exception! exception, rendering: 500
      render_error exception, :bad,            'Server Error'
    end
  end

  def report_exception! exception, context={}
    threadable.report_exception! exception, context.merge(
      request_url:    request.url,
      request_params: request.params,
      request_method: request.request_method,
      request_xhr:    request.xhr?,
    )
  end

  def render_error exception, status, message
    message = exception && exception.message != exception.class.name && exception.message.presence || message

    respond_to do |format|
      format.json {
        render json: {error: message}, status: status
      }
      format.html {
        case
        when request.xhr?
          render nothing: true, status: status
        when status == :unauthorized && !signed_in?
          redirect_to(request.get? ? sign_in_path(r: request.original_url) : sign_in_path)
        when status == :not_found
          render 'errors/not_found', status: status
        else
          render 'errors/internal_server_error', status: status
        end
      }
      format.all {
        render nothing: true, layout: false, status: :not_acceptable
      }
    end
  end

end
