module RSpec::Support::IncomingEmailParams

  class Factory < MethodObject

    def project
      @options[:project] ||= @covered.projects.find_by_slug!('raceteam')
    end
    def creator
      @options[:creator] ||= project.members.find_by_email_address!('alice@ucsd.covered.io')
    end

    def call covered, options={}
      @covered, @options = covered, options
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
      @options[:envelope_from]      ||= creator.email_address
      @options[:from]               ||= creator.formatted_email_address
      @options[:in_reply_to_header] ||= ''
      @options[:message_id]         ||= "<#{SecureRandom.uuid}@mail.example.com>"
      @options[:recipient]          ||= project.email_address
      @options[:references]         ||= ''
      @options[:sender]             ||= creator.email_address
      @options[:stripped_html]      ||= Sanitize.clean(@options[:body_html])
      @options[:stripped_text]      ||= Sanitize.clean(@options[:body_plain])
      @options[:subject]            ||= %(I'll be away on vacation all next week)
      @options[:to]                 ||= project.formatted_email_address

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
        "subject"          => @options[:subject],
        "from"             => @options[:from],
        "X-Envelope-From"  => @options[:envelope_from],
        "Sender"           => @options[:sender],
        "In-Reply-To"      => @options[:in_reply_to_header],
        "References"       => @options[:references],
        "From"             => @options[:from],
        "Date"             => @options[:date].rfc2822,
        "Message-Id"       => @options[:message_id],
        "Subject"          => @options[:subject],
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
    Factory.call(covered, options)
  end

end
