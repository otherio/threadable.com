class Covered::IncomingEmail < Covered::Model

  self.model_name = ::IncomingEmail.model_name

  def initialize covered, incoming_email_record
    @covered, @incoming_email_record = covered, incoming_email_record
  end
  attr_reader :covered, :incoming_email_record

  delegate *%w{
    id
    to_param
    params
    processed?
    bounced?
    held?
    created_at
    errors
    persisted?
    save!
  }, to: :incoming_email_record

  def reload!
    incoming_email_record.reload
    self
  end

  def processed!
    incoming_email_record.processed = true
    incoming_email_record.save!
  end

  def bounced!
    incoming_email_record.bounced = true
    incoming_email_record.save!
  end

  def held!
    incoming_email_record.held = true
    incoming_email_record.save!
  end

  def process!
    Process.call(self) unless processed?
  end

  def deliver!
    Deliver.call(self) unless delivered?
  end

  def hold!
    return if held?
    covered.emails.send_email(:message_held_notice, self)
    held!
  end

  def unhold!
    incoming_email_record.held = false
    incoming_email_record.save!
  end

  def bounce!
    Bounce.call(self) unless bounced?
  end

  def accept!
    deliver!
    covered.emails.send_email(:message_accepted_notice, self)
  end

  def reject!
    covered.emails.send_email(:message_rejected_notice, self)
    incoming_email_record.delete
  end

  def creator_is_a_organization_member?
    return false if organization.nil? || creator.nil?
    organization.members.include?(creator)
  end

  # delegated methods:
  #   processed?
  #   bounced?
  #   held?

  def delivered?
    processed? && !held? && !bounced? && message.present?
  end

  def bounceable?
    organization.nil? || !subject_valid?
  end

  def holdable?
    !bounceable? && (parent_message.nil? && !creator_is_a_organization_member?)
  end

  def deliverable?
    !bounceable? && !holdable?
  end

  def subject_valid?
    PrepareEmailSubject.call(organization, self).present?
  end


  def subject
    params['subject']
  end

  def message_id
    params['Message-Id']
  end

  def from
    params['from']
  end

  def envelope_from
    params['X-Envelope-From']
  end

  def sender
    params['sender']
  end

  def recipient
    params['recipient']
  end

  def to
    params['To']
  end

  def cc
    params['Cc']
  end

  def content_type
    params['Content-Type']
  end

  def date
    @date ||= Time.parse(params['Date']).in_time_zone
  end

  def in_reply_to
    params['In-Reply-To']
  end

  def references
    params['References']
  end

  def message_headers
    @message_headers ||= JSON.parse(params['message-headers'])
  end

  def message_headers_as_hash
    @message_headers_as_hash ||= Hash[message_headers]
  end

  def body_html
    params['body-html']
  end

  def body_plain
    params['body-plain']
  end

  def stripped_html
    params['stripped-html']
  end

  def stripped_plain
    params['stripped-text']
  end



  def from_email_addresses
    ExtractEmailAddresses.call(from, envelope_from, sender).uniq
  end

  def find_organization!
    return self if organization
    self.organization = covered.organizations.find_by_email_address(recipient)
    return self
  end

  # find a message that's message id matches this incoming email's message id
  def find_message!
    return self if message || organization.nil?
    self.message = organization.messages.find_by_message_id_header(message_id)
    return self
  end

  def find_creator!
    return self if creator
    users = covered.users.find_by_email_addresses(from_email_addresses)
    self.creator = users.find{|user| organization.members.include?(user) } if organization.present?
    self.creator ||= users.compact.first
    return self
  end

  def find_parent_message!
    return self if parent_message || organization.nil?
    self.parent_message = organization.messages.find_by_child_message_header(params)
    return self
  end

  def find_conversation!
    return self if conversation
    return find_parent_message!
  end

  # associations

  def attachments
    @attachments ||= Attachments.new(self)
  end

  def organization= organization
    if organization.try(:organization_record).present?
      @organization = organization
      incoming_email_record.organization = organization.organization_record
    else
      @organization = incoming_email_record.organization = nil
    end
  end

  def organization
    return unless incoming_email_record.organization
    @organization ||= Covered::Organization.new(covered, incoming_email_record.organization)
  end

  def message= message
    if message.try(:message_record).present?
      @message = message
      incoming_email_record.message = message.message_record
      self.creator        = message.creator
      self.conversation   = message.conversation
      self.parent_message = message.parent_message
    else
      @message = incoming_email_record.message = nil
    end
  end

  def message
    return unless incoming_email_record.message
    @message ||= Covered::Message.new(covered, incoming_email_record.message)
  end

  def creator= creator
    @creator = creator
    incoming_email_record.creator = creator.try(:user_record)
  end

  def creator
    return unless incoming_email_record.creator
    @creator ||= Covered::User.new(covered, incoming_email_record.creator)
  end

  def parent_message= parent_message
    if parent_message.try(:message_record).present?
      if self.conversation && parent_message.conversation != self.conversation
        raise  ArgumentError, 'invalid parent message. Conversations are not the same'
      end
      @parent_message = parent_message
      incoming_email_record.parent_message = parent_message.message_record
      self.conversation ||= parent_message.conversation
    else
      @parent_message = incoming_email_record.parent_message = nil
    end
  end

  def parent_message
    return unless incoming_email_record.parent_message
    @parent_message ||= Covered::Message.new(covered, incoming_email_record.parent_message)
  end

  def conversation= conversation
    @conversation = conversation
    incoming_email_record.conversation = conversation.try(:conversation_record)
  end

  def conversation
    return unless incoming_email_record.conversation
    @conversation ||= Covered::Conversation.new(covered, incoming_email_record.conversation)
  end




  delegate *%w{header multipart?}, to: :mail_message

  class MailgunRequestToEmail < ::Incoming::Strategies::Mailgun
    setup :api_key => Covered.config('mailgun')['key']
  end
  def mail_message
    @mail_message ||= MailgunRequestToEmail.new(self).message
  end




  def inspect
    details = {
      id:              id,
      processed:       processed?,
      bounced:         bounced?,
      held:            held?,
      delivered:       delivered?,
      from:            from,
      creator_id:      incoming_email_record.creator_id,
      organization_id:      incoming_email_record.organization_id,
      conversation_id: incoming_email_record.conversation_id,
      message_id:      incoming_email_record.message_id,
    }.map{|k,v| "#{k}: #{v.inspect}"}.join(', ')
    %(#<#{self.class} #{details}>)
  end

end
