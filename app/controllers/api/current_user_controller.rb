class Api::CurrentUserController < ApiController

  # GET /api/users/:id
  def show
    render json: Api::CurrentUserSerializer[current_user]
  end

end
