class Task < Conversation

  has_many :events, class_name: 'Task::Event', foreign_key: 'conversation_id'
  has_and_belongs_to_many :doers, class_name: 'User', join_table: 'task_doers'

  validates_presence_of :position

  default_scopes.clear
  default_scope -> { unscoped.order('conversations.position ASC') }

  acts_as_list :scope => :project

  scope :done, ->{ where('conversations.done_at IS NOT NULL') }
  scope :not_done, ->{ where('conversations.done_at IS NULL') }
  scope :with_doers, ->{ includes(:doers).where('task_doers.id IS NOT NULL').references(:doers) }
  scope :without_doers, ->{
    joins('LEFT JOIN task_doers ON task_doers.task_id = conversations.id').
      where('task_doers.task_id IS NULL')
  }

  before_validation :set_position

  attr_accessor :current_user

  def done! current_user, at=Time.now
    return if done?
    transaction do
      update! done_at: at
      events.create! type: 'Task::DoneEvent', user: current_user
    end
  end

  def undone! current_user
    return unless done?
    transaction do
      update! done_at: nil
      events.create! type: 'Task::UndoneEvent', user: current_user
    end
  end

  def done?
    done_at.present?
  end

  def task?
    true
  end

  def add_doers current_user, *doers
    transaction do
      self.doers += doers
      events = doers.map do |doer|
        {
          type: 'Task::AddedDoerEvent',
          user: current_user,
          doer: doer,
        }
      end
      self.events.create!(events)
    end
  end

  def remove_doers current_user, *doers
    transaction do
      self.doers -= doers
      events = doers.map do |doer|
        {
          type: 'Task::RemovedDoerEvent',
          user: current_user,
          doer: doer,
        }
      end
      self.events.create!(events)
    end
  end

  private

  def set_position
    self.position ||= project.tasks.count + 1 if project
  end

end

require_dependency "#{Rails.root}/app/models/task/event"
require_dependency "#{Rails.root}/app/models/task/created_event"
require_dependency "#{Rails.root}/app/models/task/done_event"
require_dependency "#{Rails.root}/app/models/task/undone_event"
