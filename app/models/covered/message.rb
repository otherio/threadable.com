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

  def organization
    conversation.try(:organization)
  end

  def date_header
    @date_header ||= message_record.date_header.presence || created_at.rfc2822
  end

  def sent_at
    @sent_at ||= Time.parse(date_header)
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

  def body
    Body.call(body_html, body_plain)
  end

  def stripped_body
    Body.call(stripped_html, stripped_plain)
  end
  alias_method :body_stripped, :stripped_body

  def html?
    body.html?
  end

  def root?
    parent_message_id.nil?
  end

  def avatar_url
    return unless creator # eventually this will do something for msgs with no creator.
    creator.avatar_url
  end

  def sender_name
    if creator
      creator.name
    else
      from
    end
  end

  let(:attachments){ Attachments.new(self) }

  def update attributes
    message_record.update_attributes(attributes)
  end


  delegate :recipients, to: :conversation

  def send_emails! send_to_creator=false
    recipients.all.each do |recipient|
      next if !send_to_creator && recipient.same_user?(creator)
      next if sent_to? recipient
      covered.emails.send_email_async(:conversation_message, conversation.organization.id, id, recipient.id)
      sent_to! recipient
    end
  end

  def sent_to? recipient
    message_record.sent_emails.where(user_id: recipient.user_id).exists?
  end

  def sent_email recipient
    message_record.sent_emails.where(user_id: recipient.user_id).first
  end

  def sent_to! recipient
    message_record.sent_emails.create!(
      user_id: recipient.user_id,
      email_address_id: recipient.email_addresses.primary.id,
    )
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
      body_stripped:     body_stripped,
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
