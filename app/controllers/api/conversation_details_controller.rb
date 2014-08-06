class Api::ConversationDetailsController < ApiController

  # get /api/conversation_details/:id
  def show
    render json: serialize(:conversation_details, conversation)
  end

  private

  def organization
    @organization ||= current_user.organizations.find_by_slug!(params.require(:organization_id))
  end

  def conversation
    @conversation ||= organization.conversations.find_by_slug!(params[:id])
  end

end
