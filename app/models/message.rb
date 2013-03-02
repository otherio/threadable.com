class Message < ActiveRecord::Base

  belongs_to :conversation, :counter_cache => true
  belongs_to :parent_message, :class_name => 'Message', :foreign_key => 'parent_id'
  belongs_to :user

  default_scope order('messages.created_at ASC')

  attr_accessible :body, :children, :message_id_header, :references_header, :reply, :subject, :from, :user, :parent_message

  scope :by_created_at, order('messages.created_at DESC')

  before_create :touch_conversation_update_at
  after_initialize :add_message_id

  validates_presence_of :body

  private

  def touch_conversation_update_at
    conversation.touch(:updated_at)
  end

  def add_message_id
    self.message_id_header = "#{Mail.random_tag}@multifyapp.com"
  end
end
