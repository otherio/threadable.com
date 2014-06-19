class Threadable::Messages::Create < MethodObject

  include Let

  OPTIONS = Class.new OptionsHash do
    required :conversation
    optional :from, :subject, :parent_message, :attachments
    optional :body, :text, :html
    optional :creator, :creator_id
    optional :body_plain, :body_html, :stripped_plain, :stripped_html
    optional :message_id_header, :references_header, :date_header
    optional :to_header, :cc_header
    optional :thread_index_header, :thread_topic_header
    optional :sent_via_web, default: false
  end

  def call messages, options
    @messages      = messages
    @threadable    = messages.threadable
    @options       = OPTIONS.parse(options)
    @conversation  = @options.conversation

    create_message!
    if @message.persisted?
      track!
      create_attachments!
      @message.send_emails! @options.sent_via_web
    end
    return @message
  end

  let :body_plain do
    @options.given?(:body_plain) ? @options.body_plain :
    @options.given?(:text)       ? @options.text :
    @options.given?(:body)       ? strip_html(@options.body) :
    nil
  end

  let :body_html do
    @options.given?(:body_html)  ? @options.body_html :
    @options.given?(:body)       ? @options.body :
    nil
  end

  let :stripped_plain do
    @options.stripped_plain.presence || body_plain
  end

  let :stripped_html do
    @options.stripped_html.presence || body_html
  end

  let :subject do
    @options.given?(:subject) ? @options.subject : @conversation.subject
  end

  let :parent_message do
    @options.parent_message || @conversation.messages.latest
  end

  let :from do
    @options.given?(:from) ? @options.from : creator.try(:formatted_email_address)
  end

  let :creator do
    @options.creator || (@options.creator_id && @threadable.users.find_by_id!(@options.creator_id))
  end

  let :creator_id do
    creator.try(:id)
  end

  let :message_id_header do
    @options.message_id_header || "<#{Mail.random_tag}@#{@threadable.email_host}>"
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

  let :thread_index_header do
    @options.thread_index_header
  end

  let :thread_topic_header do
    @options.thread_topic_header
  end

  def create_message!
    @message_record = @conversation.conversation_record.messages.create(
      parent_message_id:   parent_message.try(:id),
      subject:             subject,
      from:                from,
      creator_id:          creator_id,
      body_plain:          body_plain || "",
      body_html:           clean_up_html(body_html) || "",
      stripped_plain:      stripped_plain,
      stripped_html:       clean_up_html(stripped_html),
      message_id_header:   message_id_header,
      references_header:   references_header.try(:strip),
      to_header:           to_header,
      cc_header:           cc_header,
      date_header:         date_header,
      thread_index_header: thread_index_header,
      thread_topic_header: thread_topic_header
    )

    @message_record.index!

    @conversation.update(last_message_at: @message_record.created_at)
    @conversation.update_participant_names_cache!
    @conversation.update_message_summary_cache!
    @message = Threadable::Message.new(@threadable, @message_record)
  end

  def create_attachments!
    return unless @options.attachments.present?

    @message_record.attachments = @options.attachments.to_a.map do |attachment|
      case attachment
      when ::Attachment; attachment
      when ::Threadable::Attachment; attachment.attachment_record
      when Hash
        @threadable.attachments.create(attachment).attachment_record
      end
    end
  end

  def track!
    @threadable.track("Composed Message", {
      'Organization' => @conversation.organization.id,
      'Conversation' => @conversation.id,
      'Organization Name' => @conversation.organization.name,
      'Reply' => parent_message.try(:id) ? true : false,
      'Task' => @conversation.task?,
      'Message ID' => message_id_header,
    })
  end

  def strip_html(html)
    StripHtml.call(html)
  end

  def clean_up_html body
    CorrectHtml.call(body) unless body.nil?
  end


end
