class Task < Conversation

  has_many :events, foreign_key: 'conversation_id'
  has_and_belongs_to_many :doers, class_name: 'User', join_table: 'task_doers'

  validates_presence_of :position

  default_scopes.clear
  default_scope { unscoped.order('conversations.position ASC') }

  acts_as_list :scope => :project

  scope :done, ->{ where('conversations.done_at IS NOT NULL') }
  scope :not_done, ->{ where('conversations.done_at IS NULL') }
  scope :with_doers, ->{ includes(:doers).where('task_doers.id IS NOT NULL').references(:doers) }
  scope :without_doers, ->{
    joins('LEFT JOIN task_doers ON task_doers.task_id = conversations.id').
      where('task_doers.task_id IS NULL')
  }

  before_validation :set_position

  def done?
    done_at.present?
  end

  private

  def set_position
    self.position ||= project.tasks.count + 1 if project
  end

end
