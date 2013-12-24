require 'ffaker'

class IncomingEmailParamsFactory < MethodObject

  def call options={}
    @options = options
    set_defaults!
    define_params!
    return @params
  end

  def set_defaults!
    # mailgun params
    @options[:timestamp]     ||= Time.now.to_i.to_s
    @options[:token]         ||= SecureRandom.uuid
    @options[:signature]     ||= MailgunSignature.encode(@options[:timestamp], @options[:token])

    # message
    @options[:subject]       ||= %(I'll be away on vacation all next week)
    @options[:message_id]    ||= "<#{SecureRandom.uuid}@mail.example.com>"

    # from email addresses
    @options[:from]          ||= "Alice Neilson <alice@ucsd.example.com>"
    @options[:envelope_from] ||= "alice@ucsd.example.com"
    @options[:sender]        ||= @options[:envelope_from]

    # to email addresses
    @options[:recipient]     ||= 'raceteam@127.0.0.1'
    @options[:to]            ||= "UCSD Electric Racing <raceteam@127.0.0.1>"
    @options[:cc]            ||= ''

    @options[:content_type]  ||= %(multipart/alternative; boundary="f46d0438942f7e6e4a04ebf98c9c")
    @options[:date]          ||= 1.second.ago
    @options[:date] = Time.parse(@options[:date].to_s).in_time_zone # round off milliseconds

    # threading
    @options[:in_reply_to]   ||= ''
    @options[:references]    ||= ''

    # content
    @options[:body_html]     ||= Faker::Email.html_body
    @options[:body_plain]    ||= Faker::Email.plain_body
    @options[:stripped_html] ||= Sanitize.clean(@options[:body_html])
    @options[:stripped_text] ||= Sanitize.clean(@options[:body_plain])
    @options[:attachments]   ||= []

    # headers
    @options[:message_headers] ||= [
      ["X-Envelope-From", @options[:envelope_from]],
      ["Sender",          @options[:sender]],
      ["In-Reply-To",     @options[:in_reply_to]],
      ["References",      @options[:references]],
      ["From",            @options[:from]],
      ["Date",            @options[:date].rfc2822],
      ["Message-Id",      @options[:message_id]],
      ["Subject",         @options[:subject]],
      ["To",              @options[:to]],
      ["Cc",              @options[:cc]],
      ["Content-Type",    @options[:content_type]],
    ]
  end

  def define_params!
    # http://documentation.mailgun.net/user_manual.html#parsed-messages-parameters
    @params = {
      "timestamp"        => @options[:timestamp],
      "token"            => @options[:token],
      "signature"        => @options[:signature],
      "recipient"        => @options[:recipient],
      "sender"           => @options[:sender],
      "Sender"           => @options[:sender],
      "subject"          => @options[:subject],
      "Subject"          => @options[:subject],
      "from"             => @options[:from],
      "From"             => @options[:from],
      "X-Envelope-From"  => @options[:envelope_from],
      "In-Reply-To"      => @options[:in_reply_to],
      "References"       => @options[:references],
      "Date"             => @options[:date].rfc2822,
      "Message-Id"       => @options[:message_id],
      "To"               => @options[:to],
      "Cc"               => @options[:cc],
      "Content-Type"     => @options[:content_type],
      "message-headers"  => @options[:message_headers].to_json,
      "body-plain"       => @options[:body_plain],
      "body-html"        => @options[:body_html],
      "stripped-html"    => @options[:stripped_html],
      "stripped-text"    => @options[:stripped_text],
    }

    if @options[:attachments].present?
      @params['attachment-count'] = @options[:attachments].count.to_s
      @options[:attachments].each_with_index do |attachment, index|
        @params["attachment-#{index+1}"] = attachment
      end
    end
  end

end
