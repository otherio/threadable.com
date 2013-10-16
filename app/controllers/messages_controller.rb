class MessagesController < ApplicationController

  before_filter :require_user_be_signed_in!

  # POST /:project_id/conversations/:conversation_id/messages
  # POST /:project_id/conversations/:conversation_id/messages.json
  def create
    message_attributes = params.require(:message).permit(:body, :attachments)
    message_attributes[:attachments] = params[:message][:attachments]

    @message = ConversationMessageCreator.call(current_user, conversation, message_attributes)

    if @message.persisted?
      render status: :created, location: project_conversation_messages_path(conversation.project, conversation)
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end


  # PUT /:project_id/conversations/:conversation_id/messages/:id
  # PUT /:project_id/conversations/:conversation_id/messages/:id.json
  def update
    @message = conversation.messages.find(params[:id])
    message_params = params.require(:message).permit(:shareworthy, :knowledge)

    if @message.update_attributes(message_params)
      json = @message.as_json
      json[:as_html] = view_context.render_widget :message, @message
      render json: json
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  private

  def project
    @project ||= current_user.projects.where(slug: params[:project_id]).first!
  end

  def conversation
    @conversation ||= project.conversations.where(slug: params[:conversation_id]).first!
  end

end
