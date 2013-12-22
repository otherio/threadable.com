class MessagesController < ApplicationController

  before_filter :require_user_be_signed_in!

  # POST /:organization_id/conversations/:conversation_id/messages
  # POST /:organization_id/conversations/:conversation_id/messages.json
  def create
    body = params.require(:message).require(:body)
    attachments = Array(params[:message][:attachments]).map do |attachment|
      attachment.slice(:url, :filename, :mimetype, :size, :writeable).symbolize_keys
    end

    message = conversation.messages.create(
      creator:        current_user,
      sent_via_web:   true,
      body:           body,
      attachments:    attachments,
      parent_message: conversation.messages.latest,
    )

    if message.persisted?
      render json: message_as_json(message), status: :created, location: organization_conversation_messages_path(organization, conversation)
    else
      render json: message.errors, status: :unprocessable_entity
    end
  end


  # PUT /:organization_id/conversations/:conversation_id/messages/:id
  # PUT /:organization_id/conversations/:conversation_id/messages/:id.json
  def update
    attributes = params.require(:message).permit(:shareworthy, :knowledge).symbolize_keys
    message = conversation.messages.find_by_id! params[:id]
    message.update(attributes)

    if message.persisted?
      render json: message_as_json(message)
    else
      render json: message.errors, status: :unprocessable_entity
    end
  end

  private

  def organization
    @organization ||= current_user.organizations.find_by_slug! params[:organization_id]
  end

  def conversation
    @conversation ||= organization.conversations.find_by_slug! params[:conversation_id]
  end

  def organization_slug
    params.require(:organization_id)
  end

  def conversation_slug
    params.require(:conversation_id)
  end

  def message_id
    params.require(:id)
  end

  def message_as_json message
    message.as_json.merge(as_html: render_widget(:message, message))
  end

end
