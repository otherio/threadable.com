class Api::ConversationsController < ApiController

  # get /api/conversations
  def index
    render json: serialize(conversations.all)
  end

  # post /api/conversations
  def create
    conversation_params = params[:conversation].permit(:subject, :task)
    conversation_params.require :subject

    conversation = organization.conversations.create! conversation_params.symbolize_keys
    group_ids = Array(params[:conversation][:group_ids])
    conversation.groups.add organization.groups.find_by_email_address_tags!(group_ids) if group_ids

    render json: serialize(conversation), status: 201
  end

  # get /api/conversations/:id
  def show
    conversation = conversations.find_by_slug!(params[:id])
    render json: serialize(conversation)
  end

  # patch /api/conversations/:id
  def update

  end

  private

  def organization
    organization_id = params[:organization_id] || params[:conversation][:organization_id]
    @organization ||= (current_user.organizations.find_by_slug!(organization_id) if organization_id)
  end

  def group
    @group ||= (organization.groups.find_by_email_address_tag!(params[:group_id]) if params.key?(:group_id))
  end

  def conversations
    if group.present?
      @conversations ||= group.conversations
    else
      @conversations ||= organization.conversations
    end
  end

end
