class Api::CurrentUserController < ApiController

  skip_before_action :require_user_be_signed_in!

  # GET /api/users/:id
  def show
    render json: Api::CurrentUserSerializer[current_user]
  end

end
