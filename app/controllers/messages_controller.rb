class MessagesController < ApplicationController

  # POST /:project_id/conversations/:conversation_id/messages
  # POST /:project_id/conversations/:conversation_id/messages.json
  def create
    # TODO: prefetch the user and parent message
    @message = conversation.messages.new(params[:message])
    @message.user = current_user

    if @message.save
      conversation.project.members.each do |user|
        puts "queueing message to #{user.email} for #{conversation.subject}"
        SendConversationMessageWorker.enqueue({recipient: "foo" })
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
