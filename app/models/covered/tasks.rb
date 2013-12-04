class Covered::Tasks < Covered::Conversations

  autoload :Create

  def find_by_slug! slug
    find_by_slug(slug) or raise Covered::RecordNotFound, "unable to find Task with slug #{slug.inspect}"
  end

  def find_by_id! id
    find_by_id(id) or raise Covered::RecordNotFound, "unable to find Task with id #{slug.inspect}"
  end

  def create attributes
    Create.call(self, attributes)
  end

  def create! attributes
    task = create(attributes)
    task.persisted? or raise Covered::RecordInvalid, "Task invalid: #{task.errors.full_messages.to_sentence}"
    task
  end

  private

  def scope
    Task.all
  end

end
