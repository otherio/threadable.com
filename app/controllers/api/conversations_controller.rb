class Api::ConversationsController < ApiController

  # get /api/conversations
  def index
    render json: Api::ConversationsSerializer[conversations.all]
  end

  # post /api/conversations
  def create
    conversation_params = params[:conversation].permit(:subject)
    conversation_params.require :subject
    conversation = organization.conversations.create! conversation_params.symbolize_keys
    render json: Api::ConversationsSerializer[conversation], status: 201
  end

  # get /api/conversations/:id
  def show
    conversation = conversations.find_by_slug!(params[:id])
    render json: Api::ConversationsSerializer[conversation]
  end

  # patch /api/conversations/:id
  def update

  end

  private

  def organization
    @organization ||= current_user.organizations.find_by_slug!(params[:organization_id]) if params.key?(:organization_id)
  end

  def group
    @group ||= organization.groups.find_by_email_address_tag!(params[:group_id]) if params.key?(:group_id)
  end

  def conversations
    if group.present?
      @conversations ||= group.conversations
    else
      @conversations ||= organization.conversations
    end
  end

end
