class Api::ConversationsController < ApiController

  # get /api/conversations
  def index
    organization_slug = params.require(:organization)
    group_slug        = params.require(:group)
    scope             = params.require(:scope)
    page              = params.require(:page).to_i

    organization = current_user.organizations.find_by_slug!(organization_slug)

    group = case group_slug
    when 'my';        organization.my
    when 'trash';     organization.trash
    else; organization.groups.find_by_slug!(group_slug)
    end

    conversations = case scope
    when 'muted_conversations';     group.muted_conversations(page)
    when 'not_muted_conversations'; group.not_muted_conversations(page)
    when 'done_tasks';              group.done_tasks(page)
    when 'not_done_tasks';          group.not_done_tasks(page)
    when 'done_doing_tasks';        group.done_doing_tasks(page)
    when 'not_done_doing_tasks';    group.not_done_doing_tasks(page)
    else
      raise ActionController::ParameterMissing, "unknown scope: #{scope.inspect}"
    end

    render json: serialize(:conversations, conversations)
  end

  def search
    query           = params.require(:q)
    organization_id = params.require(:organization_id)
    group_slug      = params.require(:group)

    organization = current_user.organizations.find_by_id!(organization_id)

    tag_filters = ["organization_#{organization.id}"]

    tag_filters << case group_slug
    when 'my'
      current_user.group_ids.map{|id| "group_#{id}"}
    else
      "group_#{organization.groups.find_by_slug!(group_slug).id}"
    end

    puts "tag_filters: #{tag_filters.inspect}"

    search_results = Message.algolia_raw_search(query, tagFilters: tag_filters)
    conversation_ids = search_results["hits"].map{|h| h["conversation_id"] }.uniq

    conversations = Conversation.where(id: conversation_ids).map do |conversation|
      Threadable::Conversation.new(threadable, conversation)
    end
    render json: serialize(:conversations, conversations)
  end

  # post /api/conversations
  def create
    conversation_params = params.require(:conversation).permit(:subject, :task)
    conversation_params.require :subject

    conversation_params[:creator] = current_user
    group_ids = Array(params[:conversation][:group_ids])
    conversation_params[:groups] = organization.groups.find_by_ids(group_ids) if group_ids
    conversation = organization.conversations.create! conversation_params.symbolize_keys

    render json: serialize(:conversations, conversation), status: 201
  end

  # get /api/conversations/:id
  def show
    render json: serialize(:conversations, conversation)
  end

  def sync
    conversation.sync_to_user organization.members.current_member
    render json: serialize(:conversations, conversation)
  end

  # patch /api/conversations/:id
  def update
    conversation_params = if conversation.task?
      params.require(:conversation).permit(:task, :muted, :followed, :trashed, :position, :done, doers:[:id])
    else
      params.require(:conversation).permit(:task, :muted, :followed, :trashed)
    end

    # this is way to much code for an action. We should move this into conversation update at some point - Jared
    Threadable.transaction do

      if conversation_params.key?(:task)
        task = conversation_params.delete(:task)
        @conversation = case
        when conversation.task? && !task; conversation.convert_to_conversation!
        when !conversation.task? && task; conversation.convert_to_task!
        end
      end

      if conversation_params.key?(:muted)
        conversation_params.delete(:muted) ? conversation.mute! : conversation.unmute!
      end

      if conversation_params.key?(:followed)
        conversation_params.delete(:followed) ? conversation.follow! : conversation.unfollow!
      end

      if conversation_params.key?(:trashed)
        conversation_params.delete(:trashed) ? conversation.trash! : conversation.untrash!
      end

      if params[:conversation].key?(:group_ids)
        supplied_group_ids = Array(params[:conversation][:group_ids])
        existing_group_ids = conversation.groups.all.map(&:id)
        remove_group_ids = existing_group_ids - supplied_group_ids
        conversation.groups.remove organization.groups.find_by_ids(remove_group_ids) if remove_group_ids.present?

        conversation.groups.add organization.groups.find_by_ids(supplied_group_ids) if supplied_group_ids.present?
      end

      if conversation.task?

        if conversation_params.key?(:done)
          conversation_params.delete(:done) ? conversation.done! : conversation.undone!
        end

        if params[:conversation].key?(:doers) && conversation.task?
          supplied_doer_ids = Array(conversation_params.delete(:doers)).map{ |doer| doer[:id].to_i }
          existing_doer_ids = conversation.doers.all.map(&:id)
          remove_doer_ids = existing_doer_ids - supplied_doer_ids
          conversation.doers.remove(remove_doer_ids)

          doers = supplied_doer_ids.map do |doer_id|
            organization.members.find_by_user_id!(doer_id)
          end
          conversation.doers.add(doers)
        end
      end

      conversation_params.delete(:done)

      conversation.update!(conversation_params)

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
