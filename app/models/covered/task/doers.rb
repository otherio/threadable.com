require_dependency 'covered/task'

class Covered::Task::Doers

  def initialize task
    @task = task
    @covered = task.covered
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

    Covered.transaction do
      task.task_record.doer_ids += doer_user_ids
      doer_user_ids.each do |user_id|
        @covered.events.create!(
          {
            type: 'Task::AddedDoerEvent',
            project_id: task.project.id,
            user_id: covered.current_user_id,
            doer_id: user_id,
            conversation_id: task.id,
          }
        )
      end
    end
    self
  end

  def remove *doers
    doer_user_ids = (doers.map(&:user_id) & task.task_record.doer_ids).uniq

    Covered.transaction do
      task.task_record.doer_ids -= doer_user_ids
      doer_user_ids.each do |user_id|
        @covered.events.create!(
          {
            type: 'Task::RemovedDoerEvent',
            project_id: task.project.id,
            user_id: covered.current_user.id,
            doer_id: user_id,
            conversation_id: task.id,
          }
        )
      end
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
    Covered::Task::Doer.new(task, user_record)
  end

end
