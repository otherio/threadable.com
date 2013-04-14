class MessagesController < ApplicationController

  before_filter :authenticate_user!

  # POST /:project_id/conversations/:conversation_id/messages
  # POST /:project_id/conversations/:conversation_id/messages.json
  def create
    message_attributes = params[:message].merge(parent_message: conversation.messages.last)
    message_attributes[:body_plain] = message_attributes.delete(:body)

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
    @message = conversation.messages.find_by_id!(params[:id])
    updated_message = params[:message]

    unless updated_message.except(:shareworthy, :knowledge).empty?
      render :status => :forbidden, :text => "Read-only message field"
      return
    end

    unless @message.update_attributes(updated_message)
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  private

  def project
    @project ||= current_user.projects.find_by_slug!(params[:project_id])
  end

  def conversation
    @conversation ||= project.conversations.find_by_slug!(params[:conversation_id])
  end

end
