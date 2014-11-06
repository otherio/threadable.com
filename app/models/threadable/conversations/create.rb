class Threadable::Conversations::Create < MethodObject

  OPTIONS = Class.new OptionsHash do
    required :organization, :subject
    optional :creator, :creator_id, :groups
    optional :task, default: false
  end

  def call conversations, options
    @conversations = conversations
    @threadable       = @conversations.threadable
    @options       = OPTIONS.parse(options)
    @organization  = @options.organization
    create_conversation!

    @conversation = object.new(@threadable, @conversation_record)
    return @conversation unless @conversation_record.persisted?

    add_groups!
    @conversation.update_participant_names_cache!
    create_created_at_event!

    @conversation.reload
    send_application_update!
    @conversation
  end

  def scope
    @options.task ? @organization.organization_record.tasks : @organization.organization_record.conversations
  end

  def object
    @options.task ? Threadable::Task : Threadable::Conversation
  end

  def create_conversation!
    @conversation_record = scope.create(
      subject:         @options.subject,
      creator_id:      @options.creator.try(:id) || @options.creator_id,
      last_message_at: Time.now.utc,
    )
  end

  def add_groups!
    if @options.groups.present?
      @conversation_record.groups = @options.groups.map(&:group_record)
    else
      @conversation_record.groups = [@organization.groups.primary.group_record]
    end
    @conversation.update_group_caches!
  end

  def create_created_at_event!
    event_type = @options.task ? :task_created : :conversation_created
    user_id    = @options.creator.try(:id) || @options.creator_id
    @conversation.events.create!(event_type, user_id: user_id)
  end

  def send_application_update!
    update = {
      action:        :create,
      target:        :conversation,
      target_record: @conversation,
      serializer:    :base_conversations,
    }

    update[:user_ids] = @conversation.private_permitted_user_ids if @conversation.private?

    @organization.application_update(update)
  end
end
