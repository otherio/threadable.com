module RSpec::Support::MailgunPostParams

  def generate_mailgun_post_params *args
    threadable = defined?(self.threadable) ? self.threadable : Threadable.new(host: 'example.com', port: 80)
    GenerateMailgunPostParams.call(threadable, *args)
  end

  class GenerateMailgunPostParams < MethodObject

    def call threadable, params={}
      @threadable, @params = threadable, params.symbolize_keys
      {
        "signature"        => signature,
        "recipient"        => recipient,
        "sender"           => sender,
        "subject"          => subject,
        "from"             => from,
        "X-Envelope-From"  => envelope_from,
        "Sender"           => sender,
        "In-Reply-To"      => in_reply_to,
        "References"       => references,
        "From"             => from,
        "Date"             => date.rfc2822,
        "Message-Id"       => message_id,
        "Subject"          => subject,
        "To"               => to,
        "Content-Type"     => content_type,
        "message-headers"  => [
          ["X-Envelope-From", envelope_from],
          ["Sender",          sender],
          ["In-Reply-To",     in_reply_to],
          ["References",      references],
          ["From",            from],
          ["Date",            date.rfc2822],
          ["Message-Id",      message_id],
          ["Subject",         subject],
          ["To",              to],
          ["Content-Type",    content_type],
        ].to_json,
        "body-plain"       => body_plain,
        "body-html"        => body_html,
        "stripped-html"    => stripped_html,
        "stripped-text"    => stripped_text,
        'attachment-count' => '3',
        'attachment-1'     => RSpec::Support::Attachments.uploaded_file("some.gif", 'image/gif',  true),
        'attachment-2'     => RSpec::Support::Attachments.uploaded_file("some.jpg", 'image/jpeg', true),
        'attachment-3'     => RSpec::Support::Attachments.uploaded_file("some.txt", 'text/plain', false),
      }
    end

    def self.default name, &block
      define_method name do
        return instance_variable_get("@#{name}") if instance_variable_defined?("@#{name}")
        instance_variable_set "@#{name}", instance_exec(&block)
      end
    end


    default(:token        ){ SecureRandom.uuid }
    default(:signature    ){ MailgunSignature.encode(date, token) }
    default(:organization      ){ @threadable.organizations.find_by_slug!('raceteam') or raise "member organization be blank" }
    default(:member       ){ organization.members.all.first or raise "member cannot be blank" }
    default(:sender       ){ member.email_address }
    default(:recipient    ){ organization.email_address }
    default(:to           ){ organization.formatted_email_address }
    default(:from         ){ member.formatted_email_address }
    default(:envelope_from){ member.email_address }
    default(:subject      ){ 'This mailing list is ball ARRRRRRRR!' }
    default(:content_type ){ 'multipart/alternative; boundary="089e0158ba9ec5cbb704eb3fc74e"' }
    default(:date         ){ Time.parse("Fri, 29 Nov 2013 07:44:19 +0000") }
    default(:message_id   ){ '<CABQbZ2eZb_Xc9oj=-_0WwB2rdjuC5qt-NKq6xLwaM2-Fi1gDHw@mail.gmail.com>' }
    default(:in_reply_to  ){ nil }
    default(:references   ){ nil }
    default(:body_html    ){
<<-HTML
<p>this. is. <strong>AWESOME!</strong></p>
<blockquote>
<h3>Welcome to our new threadable list!</h3>
</blockquote>
HTML
    }
    default(:body_plain){ strip_html(body_html) }
    default(:stripped_html){
<<-HTML
<p>this. is. <strong>AWESOME!</strong></p>
HTML
    }
    default(:stripped_text){ strip_html(stripped_html) }

    def strip_html html
      StripHtml.call(html)
    end

  end

end
