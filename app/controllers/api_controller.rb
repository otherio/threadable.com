class ApiController < ApplicationController

  include SerializerConcern

  prepend_before_action :ensure_request_accepts_json!

  private

  def current_user_id
    current_user_id_from_access_token || super
  end

  def current_user_id_from_access_token
    token = params[:access_token] || request.headers['Access-Token']
    token.present? or return nil
    ApiAccessToken.active.find_by_token(token).try(:user_id)
  end

  def ensure_request_accepts_json!
    return if request.accepts.include?(:json) || request.format == :json
    render_error nil, :not_acceptable, 'Not Acceptable'
  end

end
