class Covered::CurrentUser::Project::Messages

  extend ActiveSupport::Autoload

  autoload :FindByChildHeader

  def initialize project
    @project = project
  end
  attr_reader :project
  delegate :covered, to: :project

  def all
    scope.map{ |message| message_for message }
  end

  def find_by_id id
    message_for (scope.find(id) or return)
  end

  def find_by_id! id
    message = find_by_id(id)
    message or raise Covered::RecordNotFound, "unable to find conversation message with id: #{id}"
    message
  end

  def find_by_child_message_header header
    message_for (FindByChildHeader.call(project.id, header) or return)
  end

  def inspect
    %(#<#{self.class} project_id: #{project.id.inspect}>)
  end

  private

  def scope
    project.project_record.messages.includes(:conversation)
  end

  def message_for message_record
    conversation = message_record.conversation.task? ?
      Covered::CurrentUser::Project::Task.new(project, message_record.conversation) :
      Covered::CurrentUser::Project::Conversation.new(project, message_record.conversation)
    Covered::CurrentUser::Project::Conversation::Message.new(conversation, message_record)
  end

end
