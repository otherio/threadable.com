class Event < ActiveRecord::Base

  TYPES = Set[
    :conversation_created,
    :conversation_trashed,
    :conversation_untrashed,
    :task_created,
    :task_done,
    :task_added_doer,
    :task_undone,
    :task_removed_doer,
    :conversation_added_group,
    :conversation_removed_group,
  ].freeze

  serialize :content, Hash

  belongs_to :organization
  belongs_to :user

  validates :event_type,   presence: true, inclusion: { in: TYPES }
  validates :organization, presence: true

  default_scope ->{ includes(:user).order(:created_at => :asc) }

  def event_type
    read_attribute(:event_type).try(:to_sym)
  end

end
