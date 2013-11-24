class Covered::CurrentUser::Project::Conversation::Messages::Create < MethodObject

  include Let

  ATTRIBUTES = Class.new OptionsHash do
    optional :subject, :parent_message, :attachments
    optional :from, :text, :html, :body_plain, :body_html
    optional :stripped_plain, :stripped_html, :message_id_header
  end

  def call conversation, attributes
    @conversation = conversation
    @covered      = conversation.covered
    @attributes   = ATTRIBUTES.parse(attributes)
    create_message!
    if @message.persisted?
      create_attachments!
      send_emails!
    end
    return @message
  end

  let :body_plain do
    @attributes.given?(:body_plain) ? @attributes.body_plain :
    @attributes.given?(:text)       ? @attributes.text :
    @attributes.given?(:html)       ? strip_html(body_html) :
    nil
  end

  let :body_html do
    @attributes.given?(:body_html)  ? @attributes.body_html :
    @attributes.given?(:html)       ? @attributes.html :
    nil
  end

  let :stripped_plain do
    @attributes.stripped_plain
  end

  let :stripped_html do
    @attributes.stripped_html
  end

  let :subject do
    @attributes.given?(:subject) ? @attributes.subject : @conversation.subject
  end

  let :parent_message do
    @attributes.parent_message || @conversation.messages.newest
  end

  let :from do
    @attributes.given?(:from) ? @attributes.from : @covered.current_user.try(:email_address)
  end

  let :creator_id do
    @covered.current_user.try(:id)
  end

  let :message_id_header do
    @attributes.message_id_header || "<#{Mail.random_tag}@#{@covered.host}>"
  end

  let :references_header do
    "#{parent_message.references_header} #{parent_message.message_id_header}" if parent_message
  end

  def create_message!
    @message_record = @conversation.conversation_record.messages.create(
      parent_message_id: parent_message.try(:id),
      subject:           subject,
      from:              from,
      creator_id:        creator_id,
      body_plain:        body_plain,
      body_html:         body_html,
      stripped_plain:    stripped_plain,
      stripped_html:     stripped_html,
      message_id_header: message_id_header,
      references_header: references_header,
    )
    @message = Covered::CurrentUser::Project::Conversation::Message.new(@conversation, @message_record)
  end

  def create_attachments!
    @message_record.attachments = Array(@attributes.attachments).map do |attachment|
      ::Attachment.create!(attachment)
    end
  end

  def send_emails!
    @message.recipients.each do |recipient|
      @covered.emails.send_email_async(:conversation_message, @conversation.project.id, @message.id, recipient.id)
    end
  end

  def strip_html(html)
    HTMLEntities.new.decode Sanitize.clean html.gsub(%r{<br/?>}, "\n")
  end

end
