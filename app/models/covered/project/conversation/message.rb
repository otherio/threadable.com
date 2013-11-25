class Covered::Project::Conversation::Message

  extend ActiveSupport::Autoload

  autoload :Attachments
  autoload :Attachment
  autoload :Body

  def self.model_name
    ::Message.model_name
  end

  def initialize conversation, message_record
    @conversation, @message_record = conversation, message_record
  end
  attr_reader :conversation, :message_record
  delegate :covered, :project, to: :conversation

  delegate *%w{
    id
    unique_id
    to_param
    from
    subject
    message_id_header
    references_header
    shareworthy?
    knowledge?
    html?
    created_at
    persisted?
    errors
    body_html
    body_plain
    stripped_html
    stripped_plain
  }, to: :message_record

  def body
    Body.call(body_html, body_plain)
  end

  def stripped_body
    Body.call(stripped_html, stripped_plain)
  end

  def root?
    parent_message.nil?
  end


  def as_json options=nil
    {
      id:             id,
      param:          to_param,
      subject:        subject,
      body:           body,
      stripped_body:  stripped_body,
      root:           root?,
      shareworthy:    shareworthy?,
      knowledge:      knowledge?,
      created_at:     created_at,
    }
  end

  def parent_message
    return unless message_record.parent_message_id
    @parent_message ||= conversation.messages.find_by_id!(message_record.parent_message_id)
  end

  def creator
    return unless message_record.creator_id
    @creator ||= project.members.find_by_user_id!(message_record.creator_id)
  end

  def recipients
    project.members.that_get_email
  end

  def attachments
    @attachments ||= Attachments.new(self)
  end

  def update attributes
    message_record.update_attributes(attributes)
  end

  def == other
    self.class === other && other.id == id
  end

  def inspect
    %(#<#{self.class}>)
  end

end
