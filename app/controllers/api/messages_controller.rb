class Api::MessagesController < ApiController

  # get /api/organizations
  def index
    render json: serialize(conversation.messages.all)
  end

  # post /api/organizations
  def create
    message_params = params[:message].slice(
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
    @organization ||= case
    when params[:organization_id]
      current_user.organizations.find_by_slug! params[:organization_id]
    when params[:message][:organization_slug]
      current_user.organizations.find_by_slug! params[:message][:organization_slug]
    end
  end

  def conversation
    conversation_id = params[:conversation_id] || params[:message][:conversation_slug]
    @conversation ||= case
    when params[:conversation_id]
      organization.conversations.find_by_slug! params[:conversation_id]
    when params[:message][:conversation_id]
      organization.conversations.find_by_id! params[:message][:conversation_id]
    end
  end

end
