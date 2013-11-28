class Covered::Project::Conversations::Create < MethodObject

  OPTIONS = Class.new OptionsHash do
    required :subject
    optional :task, default: false
  end

  def call project, options
    @project = project
    @covered = project.covered
    @options = OPTIONS.parse(options)
    create_conversation!
    create_created_at_event! if @conversation_record.persisted?
    return object.new(@project, @conversation_record)
  end

  def scope
    @options.task ? @project.project_record.tasks : @project.project_record.conversations
  end

  def object
    @options.task ? Covered::Project::Task : Covered::Project::Conversation
  end

  def create_conversation!
    @conversation_record = scope.create(
      subject:    @options.subject,
      creator_id: @covered.current_user_id,
    )
  end

  def create_created_at_event!
    @conversation_record.class::CreatedEvent.create!(
      conversation_id: @conversation_record.id,
      project_id: @project.id,
      user_id: @covered.current_user_id,
    )
  end

end
