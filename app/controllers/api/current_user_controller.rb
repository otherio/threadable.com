class Api::CurrentUserController < ApiController

  # GET /api/users/current
  def show
    render json: serialize(:current_user, current_user)
  end

  # authenticate
  # PATCH /api/users/current
  def update
    current_user_params = params.require(:current_user).permit(:current_organization_id, :dismissed_welcome_modal)
    current_user.update!(current_user_params)
    render json: serialize(:current_user, current_user)
  end

end
