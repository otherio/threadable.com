module RSpec::Support::IncomingEmailParams

  class Factory < MethodObject

    def call options={}
      @options = options
      set_defaults!
      define_params!
      return @params
    end

    def set_defaults!
      @options[:timestamp]          ||= Time.now.to_i.to_s
      @options[:token]              ||= SecureRandom.uuid
      @options[:signature]          ||= MailgunSignature.encode(@options[:timestamp], @options[:token])
      @options[:body_html]          ||= Faker::Email.html_body
      @options[:body_plain]         ||= Faker::Email.plain_body
      @options[:cc]                 ||= ''
      @options[:content_type]       ||= %(multipart/alternative; boundary="f46d0438942f7e6e4a04ebf98c9c")
      @options[:date]               ||= Time.now
      @options[:envelope_from]      ||= "alice@ucsd.covered.io"
      @options[:from]               ||= "Alice Neilson <alice@ucsd.covered.io>"
      @options[:in_reply_to_header] ||= ''
      @options[:message_id]         ||= "<#{SecureRandom.uuid}@mail.example.com>"
      @options[:recipient]          ||= 'raceteam@127.0.0.1'
      @options[:references]         ||= ''
      @options[:sender]             ||= @options[:envelope_from]
      @options[:stripped_html]      ||= Sanitize.clean(@options[:body_html])
      @options[:stripped_text]      ||= Sanitize.clean(@options[:body_plain])
      @options[:subject]            ||= %(I'll be away on vacation all next week)
      @options[:to]                 ||= "UCSD Electric Racing <raceteam@127.0.0.1>"

      @options[:attachments] ||= [
        RSpec::Support::Attachments.uploaded_file("some.gif", 'image/gif',  true),
        RSpec::Support::Attachments.uploaded_file("some.jpg", 'image/jpeg', true),
        RSpec::Support::Attachments.uploaded_file("some.txt", 'text/plain', false),
      ]

      @options[:message_headers] ||= [
        ["X-Envelope-From", @options[:envelope_from]],
        ["Sender",          @options[:sender]],
        ["In-Reply-To",     @options[:in_reply_to_header]],
        ["References",      @options[:references]],
        ["From",            @options[:from]],
        ["Date",            @options[:date].utc.rfc2822],
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
        "In-Reply-To"      => @options[:in_reply_to_header],
        "References"       => @options[:references],
        "Date"             => @options[:date].utc.rfc2822,
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

  def create_incoming_email_params options={}
    Factory.call(options)
  end

end
