class Api::ConversationsController < ApiController

  # get /api/conversations
  def index
    render json: serialize(conversations)
  end

  # post /api/conversations
  def create
    conversation_params = params.require(:conversation).permit(:subject, :task)

    Covered.transaction do
      conversation = organization.conversations.create! conversation_params.symbolize_keys
      group_ids = Array(params[:conversation][:group_ids])
      conversation.groups.add organization.groups.find_by_ids(group_ids) if group_ids
      render json: serialize(conversation), status: 201
    end
  end

  # get /api/conversations/:id
  def show
    render json: serialize(conversation)
  end

  # patch /api/conversations/:id
  def update
    render json: serialize(conversation)
  end

  def destroy
    conversation.destroy!
    render nothing: true, status: 200
  end

  private

  def organization
    @organization ||= current_user.organizations.find_by_slug!(params.require(:organization_id))
  end

  def group?
    params.key? :group_id
  end

  def group
    @group ||= organization.groups.find_by_email_address_tag!(params.require(:group_id))
  end

  def my_conversations?
    params.key? :my
  end

  def ungrouped_conversations?
    params.key? :ungrouped
  end

  def conversations
    @conversations ||= case
      when group?;                   group.conversations.all
      when my_conversations?;        organization.conversations.my
      when ungrouped_conversations?; organization.conversations.ungrouped
      else; raise "no idea what you want bro"
    end
  end

  def conversation
    @conversation ||= organization.conversations.find_by_slug!(params[:id])
  end

end
