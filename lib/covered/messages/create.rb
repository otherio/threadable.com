class Covered::Messages::Create < Covered::Resource::Action

  option :project_slug,       required: true
  option :conversation_slug,  required: true
  option :message_attributes, required: true

  let(:conversation){
    covered.conversations.get(project_slug: project_slug, slug: conversation_slug)
  }

  attr_reader :attachments, :message

  def call
    covered.signed_in!
    Covered::Message.transaction do
      prepare_message_attributes!
      create_message!
      save_attachments!
      send_message!
      message
    end
  end

  def creator
    @creator ||= covered.current_user or raise Covered::AuthorizationError
  end

  def prepare_message_attributes!
    @attachments = Array(message_attributes.delete(:attachments))
    body = message_attributes.delete(:body)
    stripped_body = strip_html(body)
    message_attributes[:body_html]      = body
    message_attributes[:stripped_html]  = body
    message_attributes[:body_plain]     = stripped_body
    message_attributes[:stripped_plain] = stripped_body
    message_attributes[:parent_message] = conversation.messages.last
    message_attributes[:subject]      ||= conversation.subject
    message_attributes[:creator]        = creator
    message_attributes[:from]           = creator.email
  end

  def create_message!
    @message = conversation.messages.create!(message_attributes)
  end

  def save_attachments!
    message.attachments = attachments.map do |attachment|
      Covered::Attachment.create!(attachment)
    end
  end

  def send_message!
    # SendConversationMessageWorker.enqueue(message_id: message.id, email_sender: true)
    covered.background_jobs.enqueue(:send_conversation_message, message_id: message.id, email_sender: true)
  end

  def strip_html(html)
    HTMLEntities.new.decode Sanitize.clean(html.gsub(%r{<br/?>}, "\n"))
  end

end
