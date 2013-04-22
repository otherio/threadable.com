class Message < ActiveRecord::Base

  belongs_to :conversation, :counter_cache => true
  belongs_to :parent_message, :class_name => 'Message', :foreign_key => 'parent_id'
  belongs_to :user

  attr_accessible(
    :subject,
    :body_plain,
    :body_html,
    :stripped_plain,
    :stripped_html,
    :children,
    :message_id_header,
    :references_header,
    :reply,
    :from,
    :user,
    :parent_message,
    :shareworthy,
    :knowledge
  )

  scope :by_created_at, order('messages.created_at DESC')

  before_create :touch_conversation_update_at
  before_validation :add_references, :only => :create
  before_validation :message_id_header, :only => :create

  validates_presence_of :body_plain, :conversation

  def message_id_header
    smtp_domain = Rails.application.config.action_mailer.smtp_settings[:domain]
    read_attribute(:message_id_header) or \
    write_attribute(:message_id_header, "<#{Mail.random_tag}@#{smtp_domain}>")
  end

  def body
    body_plain
  end

  def root?
    parent_message.nil?
  end

  private

  def touch_conversation_update_at
    conversation.touch(:updated_at)
  end

  def add_references
    if self.parent_message
      self.references_header = "#{parent_message.references_header} #{parent_message.message_id_header}"
    end
    true
  end

end
