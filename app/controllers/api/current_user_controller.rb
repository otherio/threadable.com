class Api::CurrentUserController < ApiController

  skip_before_action :require_user_be_signed_in!

  # GET /api/users/current
  def show
    render json: Api::CurrentUserSerializer[current_user]
  end

  # authenticate
  # PATCH /api/users/current
  def update
    render text: 'not implemented yet', status: 500
  end

end
