class Api::UsersController < ApiController

  # GET /api/users/:id
  def show
    unauthorized! if params[:id].to_i != current_user.id
    render json: Api::UsersSerializer[current_user]
  end

end
