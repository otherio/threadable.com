class Covered::Conversations::Create < MethodObject

  OPTIONS = Class.new OptionsHash do
    required :project, :subject
    optional :creator, :creator_id
    optional :task, default: false
  end

  def call conversations, options
    @conversations = conversations
    @covered       = @conversations.covered
    @options       = OPTIONS.parse(options)
    @project       = @options.project
    create_conversation!
    create_created_at_event! if @conversation_record.persisted?
    return object.new(@covered, @conversation_record)
  end

  def scope
    @options.task ? @project.project_record.tasks : @project.project_record.conversations
  end

  def object
    @options.task ? Covered::Task : Covered::Conversation
  end

  def create_conversation!
    @conversation_record = scope.create(
      subject:    @options.subject,
      creator_id: @options.creator.try(:id) || @options.creator_id,
    )
  end

  def create_created_at_event!
    @covered.events.create!(
      type: "#{@conversation_record.class}::CreatedEvent",
      conversation_id: @conversation_record.id,
      project_id: @project.id,
      user_id: @options.creator.try(:id) || @options.creator_id,
    )
  end

end
