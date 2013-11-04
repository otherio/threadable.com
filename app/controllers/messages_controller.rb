class MessagesController < ApplicationController

  before_filter :require_user_be_signed_in!

  # POST /:project_id/conversations/:conversation_id/messages
  # POST /:project_id/conversations/:conversation_id/messages.json
  def create
    message_attributes = params.require(:message).permit(:body).symbolize_keys
    message_attributes[:attachments] = Array(params[:message][:attachments]).map do |attachment|
      attachment.slice(:url, :filename, :mimetype, :size, :writeable).symbolize_keys
    end

    message = covered.messages.create(
      project_slug:       project_slug,
      conversation_slug:  conversation_slug,
      message_attributes: message_attributes
    )

    if message.errors.present?
      render json: message.errors, status: :unprocessable_entity
    else
      render json: message_as_json(message), status: :created, location: project_conversation_messages_path(project_slug, conversation_slug)
    end
  end


  # PUT /:project_id/conversations/:conversation_id/messages/:id
  # PUT /:project_id/conversations/:conversation_id/messages/:id.json
  def update
    attributes = params.require(:message).permit(:shareworthy, :knowledge).symbolize_keys
    message = covered.messages.update(id: message_id, attributes: attributes)

    if message.errors.present?
      render json: message.errors, status: :unprocessable_entity
    else
      render json: message_as_json(message)
    end
  end

  private

  def project_slug
    params.require(:project_id)
  end

  def conversation_slug
    params.require(:conversation_id)
  end

  def message_id
    params.require(:id)
  end

  def message_as_json message
    message.as_json.merge(as_html: view_context.render_widget(:message, message))
  end

end
