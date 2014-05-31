class Threadable::IncomingEmail < Threadable::Model

  self.model_name = ::IncomingEmail.model_name

  def initialize threadable, incoming_email_record
    @threadable, @incoming_email_record = threadable, incoming_email_record
  end
  attr_reader :threadable, :incoming_email_record

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

  def dropped!
    processed!
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
    threadable.emails.send_email(:message_held_notice, self) unless organization.hold_all_messages?
    held!
  end

  def unhold!
    incoming_email_record.held = false
    incoming_email_record.save!
  end

  def drop!
    return if dropped?
    dropped!
  end

  def bounce!
    Bounce.call(self) unless bounced?
  end

  def accept!
    deliver!
    threadable.emails.send_email(:message_accepted_notice, self) unless organization.hold_all_messages?
  end

  def reject!
    threadable.emails.send_email(:message_rejected_notice, self) unless organization.hold_all_messages?
    incoming_email_record.delete
  end

  def creator_is_an_organization_member?
    return false if organization.nil? || creator.nil?
    organization.members.include?(creator)
  end

  def creator_is_an_owner?
    return false if organization.nil? || creator.nil? || !creator_is_an_organization_member?
    member = organization.members.find_by_user_id(creator.id)
    member.role == :owner
  end

  # delegated methods:
  #   processed?
  #   bounced?
  #   held?

  def delivered?
    processed? && !held? && !bounced? && message.present?
  end

  def dropped?
    processed? && !held? && !bounced? && ! message.present?
  end

  def bounceable?
    organization.nil? || !subject_valid? || !groups_valid?
  end

  def holdable?
    (organization.hold_all_messages? && !creator_is_an_owner? && !reply?) ||
    (groups.all?(&:hold_messages?) && !bounceable? && (!reply? && !creator_is_an_organization_member?))
  end

  def reply?
    parent_message.present?
  end

  def deliverable?
    !bounceable? && !holdable? && !droppable?
  end

  def droppable?
    !parent_message.nil? && !body_has_content?
  end

  def subject_valid?
    PrepareEmailSubject.call(organization, self).present?
  end

  def groups_valid?
    groups.map(&:email_address_tag).to_set.subset?  email_address_tags.to_set
  end

  def body_has_content?
    body = StripThreadableContentFromEmailMessageBody.call(stripped_plain)
    lines = body[0..1024].split(/\n/)
    lines.reject! do |line|
      line =~ /^\s*&(done|undone|add|remove|mute|unmute)/
    end
    true if lines.join('') =~ /\S/m
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
    @date ||= params['Date'] ? Time.parse(params['Date']).in_time_zone : Time.now.in_time_zone
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

  def thread_topic
    message_headers_as_hash['Thread-Topic']
  end

  def thread_index
    message_headers_as_hash['Thread-Index']
  end


  def from_email_addresses
    ExtractEmailAddresses.call(from, envelope_from, sender).uniq
  end

  SPECIAL_EMAIL_ADDRESS_TAGS = %w{ task }.freeze
  def email_address_tags
    @email_address_tags ||= begin
      local = recipient.strip_non_ascii.downcase.split('@').first
      @email_address_tags = local.split(/(?:\+|--)/)[1..-1] - SPECIAL_EMAIL_ADDRESS_TAGS
    end
  end

  def find_organization!
    return self if organization
    self.organization = threadable.organizations.find_by_email_address(recipient)
    return self
  end

  def find_groups!
    return self if groups.present? || organization.nil?
    self.groups = organization.groups.find_by_email_address_tags(email_address_tags)
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
    users = threadable.users.find_by_email_addresses(from_email_addresses)
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
    @organization ||= Threadable::Organization.new(threadable, incoming_email_record.organization)
  end

  def groups= groups
    @groups = groups.compact
    incoming_email_record.groups = @groups.map(&:group_record)
  end

  def groups
    @groups ||= incoming_email_record.groups.map do |group|
      Threadable::Group.new(threadable, group)
    end
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
    @message ||= Threadable::Message.new(threadable, incoming_email_record.message)
  end

  def creator= creator
    @creator = creator
    incoming_email_record.creator = creator.try(:user_record)
  end

  def creator
    return unless incoming_email_record.creator
    @creator ||= Threadable::User.new(threadable, incoming_email_record.creator)
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
    @parent_message ||= Threadable::Message.new(threadable, incoming_email_record.parent_message)
  end

  def conversation= conversation
    @conversation = conversation
    incoming_email_record.conversation = conversation.try(:conversation_record)
  end

  def conversation
    return unless incoming_email_record.conversation
    @conversation ||= Threadable::Conversation.new(threadable, incoming_email_record.conversation)
  end




  delegate *%w{header multipart?}, to: :mail_message

  class MailgunRequestToEmail < ::Incoming::Strategies::Mailgun
    setup :api_key => Threadable.config('mailgun')['key']
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
      organization_id: incoming_email_record.organization_id,
      conversation_id: incoming_email_record.conversation_id,
      message_id:      incoming_email_record.message_id,
    }.map{|k,v| "#{k}: #{v.inspect}"}.join(', ')
    %(#<#{self.class} #{details}>)
  end

end
