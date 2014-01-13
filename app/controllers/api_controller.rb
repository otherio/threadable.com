class ApiController < ApplicationController

  private

  def serializer type=nil
    type ||= self.class.name[%r{\AApi::(.+)Controller\Z},1]
    "Api::#{type.to_s.camelize}Serializer".constantize
  end

  # serialize User.all
  # serialize User.first
  # serialize :users, User.all
  # serialize :users, User.first
  def serialize type=nil, payload
    serializer(type).serialize(covered, payload)
  end

  def rescue_from_exception exception
    logger.debug "rescuing from exception: #{exception.class}(#{exception.message.inspect})"
    case exception
    when *NOT_FOUND_EXCEPTION
      render json: {error: 'Not Found'}, status: :not_found
    when *NOT_LOGGED_IN_EXCEPTION
      sign_out!
      render json: {error: 'Unauthorized'}, status: :unauthorized
    else
      covered.report_exception! exception
      render json: {error: exception.to_s}, status: :bad
    end
  end

  def render_error_page status
    render json: {error: status}, status: status
  end

end
