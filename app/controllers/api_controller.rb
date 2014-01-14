class ApiController < ApplicationController

  include SerializerConcern

  before_action :ensure_request_accepts_json!

  private

  def ensure_request_accepts_json!
    return if request.accepts.include?(:json) || request.format == :json
    render_error status: :not_acceptable, message: 'Not Acceptable'
  end

end
