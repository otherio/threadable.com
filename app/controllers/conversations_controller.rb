class ConversationsController < ApplicationController

  layout 'conversations'

  before_filter :authenticate_user!

  # GET /conversations
  # GET /conversations.json
  def index
    @conversations = project.conversations.includes(events: :user, messages: :user).load

    respond_to do |format|
      format.html { render layout: 'application' }
      format.json { render json: @conversations }
    end
  end

  # GET /conversations/new
  # GET /conversations/new.json
  def new
    @conversation = project.conversations.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @conversations }
    end
  end

  # GET /conversations/1
  # GET /conversations/1.json
  def show
    @conversation = project.conversations.
      where(slug: params[:id]).
      includes(events: :user, messages: :user).
      first!

    respond_to do |format|
      format.html {}
      format.json { render json: @conversation }
    end
  end

  # POST /conversations
  # POST /conversations.json
  def create
    message = params.require(:message).slice(:subject, :body, :attachments)
    message.permit!
    subject = message.delete(:subject)

    conversation = ConversationCreator.call(project, current_user, subject, message)

    respond_to do |format|
      if conversation.persisted?
        format.html { redirect_to project_conversation_url(project, conversation), notice: 'Conversation was successfully created.' }
        format.json { render json: conversation, status: :created, location: project_conversation_url(project, conversation) }
      else
        format.html { render action: "new" }
        format.json { render json: conversation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /conversations
  # PUT /conversations.json
  def update
    conversation_params = params.require(:conversation).permit(:subject, :done)

    if conversation_params && done = conversation_params.delete(:done)
      conversation_params[:done_at] = done == "true" ? Time.now : nil
    end
    @conversation = project.conversations.with_slug(params[:id]).first!

    respond_to do |format|
      if @conversation.update_attributes(conversation_params)
        format.html { redirect_to project_conversation_url(project, @conversation), notice: 'Conversation was successfully updated.' }
        format.json { render json: @conversation, status: :created, location: project_conversation_url(project, @conversation) }
      else
        format.html { redirect_to project_conversation_url(project, @conversation), notice: 'We were unable to update your conversation. Please try again later.' }
        format.json { render json: @conversation.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /conversations
  # POST /conversations.json
  def create_as_task
    message = params[:conversation].delete(:messages)
    @conversation = project.tasks.new(params[:conversation])
    @conversation.messages.build(message)

    respond_to do |format|
      if @conversation.save
        format.html { redirect_to project_conversation_url(project, @conversation), notice: 'Task was successfully created.' }
        format.json { render json: @conversation, status: :created, location: project_conversation_url(project, @conversation) }
      else
        format.html { render action: "new" }
        format.json { render json: @conversation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /conversations/1/mute
  # PUT /conversations/1/mute.json
  def mute
    @conversation = project.conversations.with_slug(params[:id]).first!

    respond_to do |format|
      if @conversation.mute!
        format.html { redirect_to conversation_url(project, @conversation), notice: 'Conversation was successfully muted.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @conversation.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def project
    @project ||= current_user.projects.where(slug: params.require(:project_id)).includes(:tasks).first!
  end

end
