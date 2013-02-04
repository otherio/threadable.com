class Task < ActiveRecord::Base
  attr_accessible :conversation, :done, :due_at

  has_one :conversation
  has_one :project, through: :conversation

  has_and_belongs_to_many :doers, class_name: 'User'

  def name
    conversation.subject
  end

  def slug
    conversation.slug
  end

  def done! at=Time.now
    self.done_at = at
    save!
  end

  def done?
    done_at.present?
  end

end
