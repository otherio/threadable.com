class Covered::Project::Conversations

  extend ActiveSupport::Autoload

  autoload :Create

  def initialize project
    @project = project
  end
  attr_reader :project
  delegate :covered, to: :project


  def all
    scope.map{ |conversation| conversation_for conversation }
  end

  def all_with_participants
    scope.includes(:participants).map{ |conversation| conversation_for conversation }
  end

  def find_by_id id
    conversation_for (scope.where(id: id).first or return)
  end

  def find_by_id! id
    find_by_id(id) or raise Covered::RecordNotFound, "unable to find Conversation with id #{slug.inspect}"
  end

  def find_by_slug slug
    conversation_for (scope.where(slug: slug).first or return)
  end

  def find_by_slug! slug
    find_by_slug(slug) or raise Covered::RecordNotFound, "unable to find Conversation with slug #{slug.inspect}"
  end

  def newest
    conversation_for (scope.first or return)
  end
  alias_method :latest, :newest

  def oldest
    conversation_for (scope.last or return)
  end


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


  def inspect
    %(#<#{self.class} project_id: #{project.id.inspect}>)
  end

  private

  def scope
    project.project_record.conversations
  end

  def conversation_for conversation_record
    if conversation_record.task?
      Covered::Project::Task.new(project, conversation_record)
    else
      Covered::Project::Conversation.new(project, conversation_record)
    end
  end

end
