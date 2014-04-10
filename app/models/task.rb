class Task < Conversation

  has_many :events, foreign_key: 'conversation_id'
  has_and_belongs_to_many :doers, class_name: 'User', join_table: 'task_doers'

  has_many :conversation_groups, dependent: :destroy, foreign_key: 'conversation_id'

  validates_presence_of :position

  default_scope { unscoped.order('conversations.position ASC') }

  acts_as_list :scope => :organization


  scope :done, ->{ where('conversations.done_at IS NOT NULL') }
  scope :not_done, ->{ where('conversations.done_at IS NULL') }
  scope :with_doers, ->{ includes(:doers).where('task_doers.id IS NOT NULL').references(:doers) }
  scope :without_doers, ->{
    joins('LEFT JOIN task_doers ON task_doers.task_id = conversations.id').
      where('task_doers.task_id IS NULL')
  }

  scope :doing_by, ->(user_id){
    joins('LEFT JOIN task_doers ON task_doers.task_id = conversations.id').where('task_doers.user_id = ?', user_id)
  }

  scope :not_doing_by, ->(user_id){
    joins("LEFT JOIN task_doers ON task_doers.task_id = conversations.id AND task_doers.user_id = #{user_id}").where('task_doers.user_id IS NULL')
  }



  before_validation :set_position

  def done?
    done_at.present?
  end

  def convert_to_task!
    self
  end

  def convert_to_conversation!
    update_attribute(:type, '')
    ::Conversation.find(id)
  end

  private

  def set_position
    self.position ||= organization.tasks.count + 1 if organization
  end

end
