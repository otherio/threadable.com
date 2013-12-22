class ConversationsController < ApplicationController

  layout 'conversations'

  before_filter :require_user_be_signed_in!

  # GET /conversations
  # GET /conversations.json
  def index
    @conversations = organization.conversations.all_with_participants
    @tasks         = organization.tasks.all

    respond_to do |format|
      format.html { render layout: 'application' }
      format.json { render json: @conversations }
    end
  end

  # GET /conversations/new
  # GET /conversations/new.json
  def new
    @conversation = organization.conversations.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @conversations }
    end
  end

  # GET /conversations/1
  # GET /conversations/1.json
  def show
    @conversation = organization.conversations.find_by_slug! params[:id]
      # includes(events: :user, messages: :user).

    respond_to do |format|
      format.html {}
      format.json { render json: @conversation }
    end
  end

  # POST /conversations
  # POST /conversations.json
  def create
    subject = params.require(:message).require(:subject)
    body    = params.require(:message).require(:body)
    attachments = Array(params[:message][:attachments]).map do |attachment|
      attachment.slice(:url, :filename, :mimetype, :size, :writeable).symbolize_keys
    end

    conversation = organization.conversations.create(
      creator: current_user,
      subject: subject,
    )

    respond_to do |format|
      if conversation.persisted?

        message = conversation.messages.create(
          creator:      current_user,
          sent_via_web: true,
          html:         body,
          attachments:  attachments,
        )

        if message.persisted?
          format.html { redirect_to organization_conversation_url(organization, conversation), notice: 'Conversation was successfully created.' }
          format.json {render json: conversation, status: :created, location: organization_conversation_url(organization, conversation) }
        else
          format.html { render action: "new" }
          format.json { render json: message.errors, status: :unprocessable_entity }
        end

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
    @conversation = organization.conversations.find_by_slug!(params[:id])

    respond_to do |format|
      if @conversation.update(conversation_params)
        format.html { redirect_to organization_conversation_url(organization, @conversation), notice: 'Conversation was successfully updated.' }
        format.json { render json: @conversation, status: :created, location: organization_conversation_url(organization, @conversation) }
      else
        format.html { redirect_to organization_conversation_url(organization, @conversation), notice: 'We were unable to update your conversation. Please try again later.' }
        format.json { render json: @conversation.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /conversations
  # POST /conversations.json
  def create_as_task
    message = params[:conversation].delete(:messages)
    @conversation = organization.tasks.new(params[:conversation])
    @conversation.messages.build(message)

    respond_to do |format|
      if @conversation.save
        format.html { redirect_to organization_conversation_url(organization, @conversation), notice: 'Task was successfully created.' }
        format.json { render json: @conversation, status: :created, location: organization_conversation_url(organization, @conversation) }
      else
        format.html { render action: "new" }
        format.json { render json: @conversation.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def organization
    @organization ||= current_user.organizations.find_by_slug! params[:organization_id]
  end

end
