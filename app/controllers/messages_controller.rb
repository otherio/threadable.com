class MessagesController < ApplicationController

  before_filter :require_user_be_signed_in!

  # POST /:project_id/conversations/:conversation_id/messages
  # POST /:project_id/conversations/:conversation_id/messages.json
  def create
    body = params.require(:message).require(:body)
    attachments = Array(params[:message][:attachments]).map do |attachment|
      attachment.slice(:url, :filename, :mimetype, :size, :writeable).symbolize_keys
    end

    message = conversation.messages.create(
      send_email_to_message_creator: true,
      body:         body,
      attachments:  attachments,
    )

    if message.persisted?
      render json: message_as_json(message), status: :created, location: project_conversation_messages_path(project, conversation)
    else
      render json: message.errors, status: :unprocessable_entity
    end
  end


  # PUT /:project_id/conversations/:conversation_id/messages/:id
  # PUT /:project_id/conversations/:conversation_id/messages/:id.json
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

  def project
    @project ||= current_user.projects.find_by_slug! params[:project_id]
  end

  def conversation
    @conversation ||= project.conversations.find_by_slug! params[:conversation_id]
  end

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
    message.as_json.merge(as_html: render_widget(:message, message))
  end

end
