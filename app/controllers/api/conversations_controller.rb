class Api::ConversationsController < ApiController

  # get /api/conversations
  def index
    organization_slug = params.require(:organization)
    group_slug        = params.require(:group)
    scope             = params.require(:scope)

    organization = current_user.organizations.find_by_slug!(organization_slug)

    group = case group_slug
    when 'my';        organization.my
    when 'ungrouped'; organization.ungrouped
    else; organization.groups.find_by_slug!(group_slug)
    end

    conversations = case scope
    when 'muted_conversations';     group.muted_conversations
    when 'not_muted_conversations'; group.not_muted_conversations
    when 'done_tasks';              group.done_tasks
    when 'not_done_tasks';          group.not_done_tasks
    when 'done_doing_tasks';        group.done_doing_tasks
    when 'not_done_doing_tasks';    group.not_done_doing_tasks
    else
      raise ActionController::ParameterMissing, "unknown scope: #{scope.inspect}"
    end

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

  def conversation
    @conversation ||= organization.conversations.find_by_slug!(params[:id])
  end

end
