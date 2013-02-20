class Task < Conversation
  attr_accessible :due_at, :done_at

  has_and_belongs_to_many :doers, class_name: 'User', join_table: 'task_doers'

  scope :done, where('conversations.done_at IS NOT NULL')
  scope :not_done, where('conversations.done_at IS NULL')

  after_save :create_done_event!

  def done! current_user, at=Time.now
    @current_user = current_user
    self.done_at = at
    save!
  end

  def undone! current_user
    @current_user = current_user
    self.done_at = nil
    save!
  end

  def done?
    done_at.present?
  end

  def task?
    true
  end

  private

  def create_done_event!
    if done_at_changed?
      (done? ? DoneEvent : UndoneEvent).create!(task: self, project: project, user: @current_user)
    end
  end

end

require_dependency "#{Rails.root}/app/models/task/event"
require_dependency "#{Rails.root}/app/models/task/created_event"
require_dependency "#{Rails.root}/app/models/task/done_event"
require_dependency "#{Rails.root}/app/models/task/undone_event"
