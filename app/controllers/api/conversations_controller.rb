class Api::ConversationsController < ApiController

  # get /api/conversations
  def index
    render json: serialize(:conversations, conversations)
  end

  # post /api/conversations
  def create
    conversation_params = params.require(:conversation).permit(:subject, :task)
    conversation_params.require :subject

    Covered.transaction do
      conversation = organization.conversations.create! conversation_params.symbolize_keys
      group_ids = Array(params[:conversation][:group_ids])
      conversation.groups.add organization.groups.find_by_ids(group_ids) if group_ids
      render json: serialize(:conversations, conversation), status: 201
    end
  end

  # get /api/conversations/:id
  def show
    render json: serialize(:conversations, conversation)
  end

  # patch /api/conversations/:id
  def update

    conversation_params = if conversation.task?
      params.require(:conversation).permit(:done, :muted, doers: :id)
    else
      params.require(:conversation).permit(:muted)
    end

    Covered.transaction do

      if conversation_params.key?(:done)
        conversation_params[:done] ? conversation.done! : conversation.undone!
      end

      if conversation_params.key?(:muted)
        conversation_params[:muted] ? conversation.mute! : conversation.unmute!
      end

      if params[:conversation].key?(:doers)
        supplied_doer_ids = if conversation_params[:doers].present?
          conversation_params[:doers].map{ |doer| doer[:id].to_i }
        else
          []
        end

        existing_doer_ids = conversation.doers.all.map(&:id)
        remove_doer_ids = existing_doer_ids - supplied_doer_ids
        conversation.doers.remove(remove_doer_ids)

        doers = supplied_doer_ids.map do |doer_id|
          organization.members.find_by_user_id!(doer_id)
        end
        conversation.doers.add(doers)
      end

    end

    render json: serialize(:conversations, conversation)
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
      else; raise Covered::RecordNotFound
    end
  end

  def conversation
    @conversation ||= organization.conversations.find_by_slug!(params[:id])
  end

end
