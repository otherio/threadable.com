class Covered::CurrentUser::Project::Conversations < Covered::Project::Conversations

  autoload :Create

  def build attributes={}
    conversation_for scope.build(attributes)
  end
  alias_method :new, :build

  def create attributes={}
    Create.call project, attributes
  end

  def create! attributes={}
    conversation = create(attributes)
    conversation.persisted? or raise Covered::RecordInvalid, "Conversation invalid: #{conversation.errors.full_messages.to_sentence}"
    conversation
  end

  private

  def conversation_for conversation_record
    if conversation_record.task?
      Covered::CurrentUser::Project::Task.new(project, conversation_record)
    else
      Covered::CurrentUser::Project::Conversation.new(project, conversation_record)
    end
  end

end
