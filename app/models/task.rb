class Task < Conversation
  attr_accessible :due_at, :done_at, :doers_attributes

  has_and_belongs_to_many :doers, class_name: 'User', join_table: 'task_doers'
  accepts_nested_attributes_for :doers

  scope :done, where('conversations.done_at IS NOT NULL')
  scope :not_done, where('conversations.done_at IS NULL')

  def done! at=Time.now
    self.done_at = at
    save!
  end

  def done?
    done_at.present?
  end

  def task?
    true
  end

end
