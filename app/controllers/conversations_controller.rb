class ConversationsController < ApplicationController
  # GET /conversations
  # GET /conversations.json
  def index
    @conversations = project.conversations.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @conversations }
    end
  end

  # GET /conversations/1
  # GET /conversations/1.json
  def show
    @conversation = project.conversations.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @conversation }
    end
  end

  # POST /conversations
  # POST /conversations.json
  def create
    @conversation = project.conversations.new(params[:conversation])

    respond_to do |format|
      if @conversation.save
        format.html { redirect_to conversation_url(project, @conversation), notice: 'Conversation was successfully created.' }
        format.json { render json: @conversation, status: :created, location: @conversation }
      else
        format.html { render action: "new" }
        format.json { render json: @conversation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /conversations/1/mute
  # PUT /conversations/1/mute.json
  def mute
    @conversation = project.conversations.find(params[:id])

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
    @project ||= Project.find_by_slug!(params[:project_id])
  end

end
