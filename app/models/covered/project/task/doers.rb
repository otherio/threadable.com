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


  def add *doers
    doer_user_ids = (doers.map(&:user_id) - task.task_record.doer_ids).uniq

    task.task_record.transaction do
      task.task_record.doer_ids += doer_user_ids
      events = doer_user_ids.map do |user_id|
        {
          type: 'Task::AddedDoerEvent',
          project_id: task.project.id,
          user_id: covered.current_user.id,
          doer_id: user_id,
        }
      end
      task.task_record.events.create!(events)
    end
    self
  end

  def remove *doers
    doer_user_ids = (doers.map(&:user_id) & task.task_record.doer_ids).uniq

    task.task_record.transaction do
      task.task_record.doer_ids -= doer_user_ids
      events = doer_user_ids.map do |user_id|
        {
          type: 'Task::RemovedDoerEvent',
          project_id: task.project.id,
          user_id: covered.current_user.id,
          doer_id: user_id,
        }
      end
      task.task_record.events.create!(events)
    end
    self
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
