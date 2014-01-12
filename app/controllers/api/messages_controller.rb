class Api::MessagesController < ApiController

  # get /api/organizations
  def index
    render json: serialize(conversation.messages.all)
  end

  # post /api/organizations
  def create
    message_params = params[:message].permit(
      :subject, :body, :from, :attachments, :text, :html,
      :body_plain, :body_html, :stripped_plain, :stripped_html,
      :to_header, :cc_header
    ).symbolize_keys

    message = conversation.messages.create! message_params.merge(sent_via_web: true, creator: current_user) if message_params.present?
    if message.present? && message.persisted?
      render json: serialize(message), status: 201
    else
      render nothing: true, status: 422
    end
  end

  private

  def organization
    organization_id = params[:organization_id] || params[:message][:organization_id]
    @organization ||= (current_user.organizations.find_by_slug!(organization_id) if organization_id)
  end

  def conversation
    conversation_id = params[:conversation_id] || params[:message][:conversation_id]
    @conversation ||= (organization.conversations.find_by_slug!(conversation_id) if conversation_id)
  end

end
