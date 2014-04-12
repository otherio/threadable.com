require_dependency 'threadable/task'

class Threadable::Task::Doers

  def initialize task
    @task = task
    @threadable = task.threadable
  end
  attr_reader :task
  delegate :threadable, to: :task

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
    doer_user_ids = (doers.flatten.map(&:user_id) - task.task_record.doer_ids).uniq

    Threadable.transaction do
      task.task_record.doer_ids += doer_user_ids
      doer_user_ids.each do |user_id|
        task.events.create!(:task_added_doer,
          user_id: threadable.current_user_id,
          doer_id: user_id,
        )
      end
    end
    self
  end

  def remove *doers
    doer_user_ids = (doers.flatten.map do |doer|
      doer.instance_of?(Fixnum) ? doer : doer.user_id
    end & task.task_record.doer_ids).uniq

    Threadable.transaction do
      task.task_record.doer_ids -= doer_user_ids
      doer_user_ids.each do |user_id|
        task.events.create!(:task_removed_doer,
          user_id: threadable.current_user.try(:id),
          doer_id: user_id,
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
    Threadable::Task::Doer.new(task, user_record)
  end

end
