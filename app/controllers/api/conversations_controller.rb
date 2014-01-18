class Api::ConversationsController < ApiController

  # get /api/conversations
  def index
    params.require(:organization_id)
    params.require(:context)
    params.require(:scope)
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



  def conversations
    @conversations ||= begin
      organization
      group = organization.groups.find_by_email_address_tag!(params.require(:group_id)) if params[:context] == 'group'

      case [params[:context], params[:scope]]
      when %w{ my not_muted_conversations }
        organization.conversations.my.not_muted
      when %w{ my muted_conversations }
        organization.conversations.my.muted
      when %w{ my all_task }
        organization.tasks.my.all
      when %w{ my doing_tasks }
        organization.tasks.my.doing
      when %w{ ungrouped not_muted_conversations }
        organization.conversations.ungrouped.not_muted
      when %w{ ungrouped muted_conversations }
        organization.conversations.ungrouped.muted
      when %w{ ungrouped all_task }
        organization.tasks.ungrouped.all
      when %w{ ungrouped doing_tasks }
        organization.tasks.ungrouped.doing
      when %w{ group not_muted_conversations }
        group.conversations.not_muted
      when %w{ group muted_conversations }
        group.conversations.muted
      when %w{ group all_task }
        group.tasks.all
      when %w{ group doing_tasks }
        group.tasks.doing
      else
        raise ActionController::ParameterMissing,
          "unknown context / scope combination: #{params[:context].inspect} #{params[:scope].inspect}"
      end
    end
  end

end
