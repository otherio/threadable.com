class ConversationGroup < ActiveRecord::Base

  belongs_to :group
  belongs_to :conversation

  scope :active, -> { where active: true }

end
