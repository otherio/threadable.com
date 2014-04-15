class ApiController < ApplicationController

  include SerializerConcern

  prepend_before_action :ensure_request_accepts_json!
  doorkeeper_for :all

  private

  def ensure_request_accepts_json!
    return if request.accepts.include?(:json) || request.format == :json
    render_error nil, :not_acceptable, 'Not Acceptable'
  end

end
