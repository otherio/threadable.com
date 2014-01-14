class Api::EventsController < ApiController

  # get /api/events
  def index
    render json: serialize(:events, conversation.events.with_messages)
  end

  private

  def organization
    @organization ||= case
    when params[:organization_id]
      current_user.organizations.find_by_slug! params[:organization_id]
    when params[:message][:organization_slug]
      current_user.organizations.find_by_slug! params[:message][:organization_slug]
    end
  end

  def conversation
    @conversation ||= case
    when params[:conversation_id]
      organization.conversations.find_by_slug! params[:conversation_id]
    when params[:message][:conversation_id]
      organization.conversations.find_by_id! params[:message][:conversation_id]
    end
  end

end
