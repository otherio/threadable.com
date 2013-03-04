class MessagesController < ApplicationController

  # POST /:project_id/conversations/:conversation_id/messages
  # POST /:project_id/conversations/:conversation_id/messages.json
  def create
    # TODO: prefetch the user and parent message
    last_message = conversation.messages.last
    @message = conversation.messages.new(params[:message])
    @message.user = current_user
    @message.subject ||= conversation.subject
    @message.parent_message = last_message
    reply_to = "#{project.name} <#{project.slug}@multifyapp.com>"

    if @message.save
      conversation.project.members.each do |user|
        next if user.id == current_user.id
        SendConversationMessageWorker.enqueue(
          recipient: user,
          sender: @message.user,
          message: @message,
          parent_message: @message.parent_message,
          reply_to: reply_to
        )
      end

      render status: :created, location: project_conversation_messages_path(conversation.project, conversation)
    else
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
