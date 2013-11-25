class Covered::Project::Task::Doers

  def initialize task
    @task = task
  end
  attr_reader :task
  delegate :covered, to: :task

  def all
    scope.map{ |doer| doer_for doer }
  end

  def count
    scope.count
  end

  def include? member
    !!scope.where(users: {id: member.user_id}).exists?
  end

  def inspect
    %(#<#{self.class}>)
  end

  private

  def scope
    task.task_record.doers
  end

  def doer_for user_record
    Covered::Project::Task::Doer.new(task, user_record)
  end

end
