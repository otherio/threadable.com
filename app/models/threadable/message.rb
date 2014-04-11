class Threadable::Message < Threadable::Model

  self.model_name = ::Message.model_name

  def initialize threadable, message_record
    @threadable, @message_record = threadable, message_record
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
    thread_index_header
    thread_topic_header
    created_at
    persisted?
    errors
  }, to: :message_record

  def reload
    message_record.reload
    self
  end

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
    @creator ||= Threadable::User.new(threadable, message_record.creator)
  end

  def conversation
    return unless message_record.conversation
    @conversation ||= Threadable::Conversation.new(threadable, message_record.conversation)
  end

  def parent_message
    return unless message_record.parent_message
    @parent_message ||= Threadable::Message.new(threadable, message_record.parent_message)
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
    message_record.update_attributes!(attributes)
  end


  delegate :recipients, to: :conversation

  def send_emails! send_to_creator=false
    # Scheduling background jobs need to happen outside of a Threadable.transaction so that
    # we do not stick jobs in redis right away for transactions that later fail.
    #
    # We need the below code below to also run outside of a transaction so that `sent_to! recipient`
    # (which reactes a row in the sent_emails table) throws an ActiveRecord::RecordNotUnique error
    # preventing us from trying to send the same email twice.
    Threadable.after_transaction do
      recipients.all.each do |recipient|
        next if !send_to_creator && recipient.same_user?(creator)
        send_for_recipient recipient
      end
    end
  end

  def send_email_for! recipient
    return unless recipient.gets_email? && recipient.confirmed?
    Threadable.after_transaction do
      send_for_recipient recipient
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

  def not_sent_to! recipient
    sent_record = message_record.sent_emails.where(user_id: recipient.id).first
    sent_record.destroy if sent_record.present?
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

  private

  def send_for_recipient recipient
    begin
      sent_to! recipient
    rescue ActiveRecord::RecordNotUnique
      return
    end
    threadable.emails.send_email_async(:conversation_message, conversation.organization.id, id, recipient.id)
  end
end
