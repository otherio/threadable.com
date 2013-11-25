class Covered::CurrentUser::Project::Tasks < Covered::CurrentUser::Project::Conversations

  autoload :Create

  def find_by_slug! slug
    find_by_slug(slug) or raise Covered::RecordNotFound, "unable to find Task with slug #{slug.inspect}"
  end

  def create attributes
    Create.call project, attributes
  end

  def create! attributes
    task = create(attributes)
    task.persisted? or raise Covered::RecordInvalid, "Task invalid: #{task.errors.full_messages.to_sentence}"
    task
  end

  private

  def scope
    project.project_record.tasks
  end

  alias_method :task_for, :conversation_for

end
