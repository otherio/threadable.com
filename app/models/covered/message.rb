class Covered::Message < Covered::Model

  self.model_name = ::Message.model_name

  def initialize covered, message_record
    @covered, @message_record = covered, message_record
  end
  attr_reader :message_record

  delegate *%w{
    id
    unique_id
    parent_message_id
    conversation_id
    to_param
    from
    subject
    message_id_header
    references_header
    to_header
    cc_header
    date_header
    shareworthy?
    knowledge?
    body_html
    body_plain
    stripped_html
    stripped_plain
    created_at
    persisted?
    errors
  }, to: :message_record

  def project
    conversation.try(:project)
  end

  def creator
    return unless message_record.creator
    @creator ||= Covered::User.new(covered, message_record.creator)
  end

  def conversation
    return unless message_record.conversation
    @conversation ||= Covered::Conversation.new(covered, message_record.conversation)
  end

  def parent_message
    return unless message_record.parent_message
    @parent_message ||= Covered::Message.new(covered, message_record.parent_message)
  end

  def recipients
    project.members.that_get_email
  end

  def body
    Body.call(body_html, body_plain)
  end

  def stripped_body
    Body.call(stripped_html, stripped_plain)
  end

  def html?
    body.html?
  end

  def root?
    parent_message.nil?
  end

  let(:attachments){ Attachments.new(self) }

  def update attributes
    message_record.update_attributes(attributes)
  end


  def inspect
    %(#<#{self.class} message_id: #{id.inspect}>)
  end


  def as_json options=nil
    {
      id:                id,
      conversation_id:   conversation_id,
      unique_id:         unique_id,
      parent_message_id: parent_message_id,
      param:             to_param,
      from:              from,
      subject:           subject,
      html:              html?,
      body:              body,
      stripped_body:     stripped_body,
      body_html:         body_html,
      body_plain:        body_plain,
      stripped_html:     stripped_html,
      stripped_plain:    stripped_plain,
      root:              root?,
      shareworthy:       shareworthy?,
      knowledge:         knowledge?,
      message_id_header: message_id_header,
      references_header: references_header,
      date_header:       date_header,
      created_at:        created_at,
    }
  end

end
