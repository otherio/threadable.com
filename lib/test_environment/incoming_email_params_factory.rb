class TestEnvironment::IncomingEmailParamsFactory < MethodObject.new(:overides)

  # http://documentation.mailgun.net/user_manual.html#parsed-messages-parameters
  def call
    overides  = @overides.dup
    timestamp = (overides.delete("timestamp") || Time.now.to_i - rand(10000)).to_s
    token     = overides.delete("token")     || SecureRandom.uuid

    message_headers = {
      'Message-Id' => '<3j4hjk35hk4h32423k@hackers.io>',
      # 'In-Reply-To' => parent_message.message_id_header,
    }.merge! overides.delete('message-headers') || {}

    body_html     = Faker::Email.html_body
    stripped_html = Sanitize.clean(body_html)
    body_plain    = Faker::Email.plain_body
    stripped_text = Sanitize.clean(body_plain)

    params = {
      'timestamp'        => timestamp,
      'token'            => token,
      'signature'        => MailgunSignature.encode(timestamp, token),
      'message-headers'  => message_headers.to_a.to_json,
      'from'             => 'Alice Neilson <alice@ucsd.coveredapp.com>',
      'recipient'        => 'UCSD Electric Racing <ucsd-electric-racing@coveredapp.com>',
      'subject'          => 'this is the subject',
      'body-html'        => body_html,
      'stripped-html'    => stripped_html,
      'body-plain'       => body_plain,
      'stripped-text'    => stripped_text,
      'attachment-count' => '3',
      'attachment-1'     => attachment_file("some.gif", 'image/gif',  true),
      'attachment-2'     => attachment_file("some.jpg", 'image/jpeg', true),
      'attachment-3'     => attachment_file("some.txt", 'text/plain', false),
    }

    params.merge!(overides)

    params
  end

  def fixture_path
    TestEnvironment.fixture_path
  end

  def attachment_file(path, content_type, binary)
    Rack::Test::UploadedFile.new("#{fixture_path}/attachments/#{path}", content_type, binary)
  end

end
