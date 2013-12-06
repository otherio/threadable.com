class Covered::Messages::Create < MethodObject

  include Let

  OPTIONS = Class.new OptionsHash do
    required :conversation
    optional :from, :subject, :parent_message, :attachments
    optional :body, :text, :html
    optional :creator_id
    optional :body_plain, :body_html, :stripped_plain, :stripped_html
    optional :message_id_header, :references_header, :date_header
    optional :to_header, :cc_header
    optional :sent_via_web, default: false
  end

  def call messages, options
    @messages      = messages
    @covered       = messages.covered
    @options       = OPTIONS.parse(options)
    @conversation  = @options.conversation

    # unless @options.given_options.keys

    create_message!
    if @message.persisted?
      create_attachments!
      send_emails!
    end
    return @message
  end

  let :body_plain do
    @options.given?(:body_plain) ? @options.body_plain :
    @options.given?(:text)       ? @options.text :
    @options.given?(:body)       ? strip_html(@options.body) :
    @options.given?(:html)       ? strip_html(body_html) :
    nil
  end

  let :body_html do
    @options.given?(:body)       ? @options.body :
    @options.given?(:body_html)  ? @options.body_html :
    @options.given?(:html)       ? @options.html :
    nil
  end

  let :stripped_plain do
    @options.stripped_plain
  end

  let :stripped_html do
    @options.stripped_html
  end

  let :subject do
    @options.given?(:subject) ? @options.subject : @conversation.subject
  end

  let :parent_message do
    @options.parent_message
  end

  let :from do
    @options.given?(:from) ? @options.from : creator.try(:formatted_email_address)
  end

  let :creator do
    @options.creator_id ? @covered.users.find_by_id!(@options.creator_id) : @covered.current_user
  end

  let :creator_id do
    creator.try(:id)
  end

  let :message_id_header do
    @options.message_id_header || "<#{Mail.random_tag}@#{@covered.email_host}>"
  end

  let :date_header do
    @options.date_header || Time.now.utc.rfc2822
  end

  let :references_header do
    @options.references_header || (parent_message ? "#{parent_message.references_header} #{parent_message.message_id_header}" : nil)
  end

  let :to_header do
    @options.to_header
  end

  let :cc_header do
    @options.cc_header
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
      references_header: references_header.try(:strip),
      to_header:         to_header,
      cc_header:         cc_header,
      date_header:       date_header,
    )

    @covered.track("Composed Message", {
      'Project' => @conversation.project.id,
      'Conversation' => @conversation.id,
      'Project Name' => @conversation.project.name,
      'Reply' => parent_message.try(:id) ? true : false,
      'Task' => @conversation.task?,
      'Via' => @options.sent_via_web.present? ? 'web' : 'email',
      'Message ID' => message_id_header,
    })
    @message = Covered::Message.new(@covered, @message_record)
  end

  def create_attachments!
    @message_record.attachments = @options.attachments if @options.attachments.present?
  end

  def send_emails!
    @message.recipients.each do |recipient|
      next if !@options.sent_via_web && recipient.same_user?(creator)
      @covered.emails.send_email_async(:conversation_message, @conversation.project.id, @message.id, recipient.id)
    end
  end

  def strip_html(html)
    StripHtml.call(html)
  end

end
