class Message < ActiveRecord::Base

  belongs_to :conversation, counter_cache: true
  belongs_to :parent_message, class_name: 'Message', foreign_key: 'parent_id'
  belongs_to :creator, class_name: 'User', foreign_key: 'user_id'
  has_one :project, through: :conversation
  has_and_belongs_to_many :attachments, class_name: 'Attachment'

  scope :by_created_at, ->{ order('messages.created_at DESC') }

  before_create :touch_conversation_update_at

  validates_presence_of :conversation_id, :date_header, :message_id_header

  def creator_id
    self.user_id
  end

  def creator_id= id
    self.user_id= id
  end

  def parent_message_id
    self.parent_id
  end

  def parent_message_id= id
    self.parent_id= id
  end

  def unique_id
    Base64.urlsafe_encode64 message_id_header
  end

  private

  def touch_conversation_update_at
    conversation.touch(:updated_at)
  end

end
