class Threadable::Tasks < Threadable::Conversations

  def find_by_slug! slug
    find_by_slug(slug) or raise Threadable::RecordNotFound, "unable to find Task with slug #{slug.inspect}"
  end

  def find_by_id! id
    find_by_id(id) or raise Threadable::RecordNotFound, "unable to find Task with id #{slug.inspect}"
  end

  def create attributes
    Create.call(self, attributes)
  end

  def create! attributes
    task = create(attributes)
    task.persisted? or raise Threadable::RecordInvalid, "Task invalid: #{task.errors.full_messages.to_sentence}"
    task
  end

  def all_for_user user
    conversations_for scope.task.joins(:doers).where('task_doers.user_id = ?', user.id)
  end

  private

  def scope
    Task.all
  end

end

require_dependency 'threadable/tasks/create'
