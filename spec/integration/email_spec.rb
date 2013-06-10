# Encoding: UTF-8
require 'spec_helper'

describe "email" do

  let :complex_message_body do
<<-EMAIL
Hello Steve,

American apparel occupy pour-over art party, odio flannel small batch
williamsburg. Wolf "velit commodo viral master" cleanse. Food truck
cillum qui nisi. Pickled dolor & vero cupidatat, veniam anim tonx
sustainable pitchfork keytar. Velit reprehenderit cupidatat, consectetur
sartorial gastropub 18% fap you probably haven't heard of them tofu tonx
pour-over ullamco retro meh. Qui officia eiusmod chambray, single-origin
coffee hoodie kogi selfies bushwick. Kogi biodiesel laborum mumblecore.

--
Jared
jared@other.io

EMAIL
  end

  before do
    ActionMailer::Base.stub(:default_url_options).and_return(host: 'multifyapp.com')
  end

  let(:project) { Project.find_by_name("UCSD Electric Racing") }
  let(:sender){ User.find_by_email!('alice@ucsd.multifyapp.com') }
  let(:conversation){ project.conversations.where(subject: 'layup body carbon').first! }

  context "recieving from mailgun" do

    def filter_token(body)
      EmailProcessor::UnsubscribeTokenFilterer.call(body)
    end


    let(:parent_message){ conversation.messages.first! }

    let :message_headers do
      {
        'Message-Id' => '<3j4hjk35hk4h32423k@hackers.io>',
        'In-Reply-To' => parent_message.message_id_header,
      }
    end

    # http://documentation.mailgun.net/user_manual.html#parsed-messages-parameters
    def params
      timestamp = "1370817404"
      token = "116d1b6e-3ee0-4f9c-8f77-4b7d10c42ee2"
      {
        'timestamp'        => timestamp,
        'token'            => token,
        'signature'        => MailgunSignature.encode(timestamp, token),
        'message-headers'  => message_headers.to_a.to_json,
        'from'             => 'Alice Neilson <alice@ucsd.multifyapp.com>',
        'recipient'        => 'UCSD Electric Racing <ucsd-electric-racing@multifyapp.com>',
        'subject'          => 'this is the subject',
        'body-html'        => '<div>'+complex_message_body+'</div>',
        'body-plain'       => complex_message_body,
        'stripped-html'    => '<div>'+complex_message_body+'</div>',
        'stripped-text'    => complex_message_body,
        'attachment-count' => '3',
        'attachment-1'     => fixture_file_upload("#{self.class.fixture_path}/attachments/some.gif", 'image/gif',  true),
        'attachment-2'     => fixture_file_upload("#{self.class.fixture_path}/attachments/some.jpg", 'image/jpeg', true),
        'attachment-3'     => fixture_file_upload("#{self.class.fixture_path}/attachments/some.txt", 'text/plain', false),
      }
    end

    context "when the signature is invalid" do
      it "should not so anything and render a bad request" do
        post '/emails', params.merge('signature' => 'badsignature')
        expect(response).to_not be_success
      end
    end

    context "when the signature is valid" do

      it "should create a message" do
        post '/emails', params
        expect(response).to be_success

        worker_arg = params
        EmailProcessor.encode_attachements(worker_arg)

        assert_queued ProcessEmailWorker, [worker_arg]

        ->{ Resque.run! }.should change{ Message.count }.by(1)
        message = Message.last

        assert_queued SendConversationMessageWorker, [{message_id: message.id}]

        expect(message.message_id_header).to     eq message_headers['Message-Id']
        expect(message.subject).to               eq params['subject']
        expect(message.parent_message).to        eq parent_message
        expect(message.user).to                  eq sender
        expect(message.from).to                  eq sender.email
        expect(message.body_plain).to            eq filter_token(params['body-plain'])
        expect(message.body_html).to             eq filter_token(params['body-html'])
        expect(message.stripped_plain).to        eq filter_token(params['stripped-text'])
        expect(message.stripped_html).to         eq filter_token(params['stripped-html'])
        expect(message.conversation).to          eq conversation
        expect(message.conversation.project).to  eq project

        attachment_filenames = message.attachments.map(&:filename).to_set
        expected_attachment_filenames = 1.upto(3).map{|n| params["attachment-#{n}"].original_filename}.to_set

        # TODO this should check file contents but encoding is hard :(
        expect(attachment_filenames).to eq expected_attachment_filenames

        Resque.run!

        mail_recipients = (project.members_who_get_email - [message.user])

        expected_messages = mail_recipients.map do |mail_recipient|
          {
            from: "alice@ucsd.multifyapp.com",
            to: [mail_recipient.email],
            subject: "✔ [ucsd-el] this is the subject",
          }
        end.to_set

        sent_messages = ActionMailer::Base.deliveries.map do |message|
          {
            from: message.from,
            to: message.to,
            subject: message.subject,
          }
        end

        expect(sent_messages).to eq sent_messages

      end
    end
  end

  context "recieving from the website" do

    before do
      login_via_post_as sender
    end

    context "replying to an existing conversation" do

      def params
        {message: {body: complex_message_body} }
      end

      it "should create a message and send emails through mailgun" do
        ->{
          xhr :post, project_conversation_messages_path(project, conversation), params
          response.should be_success
        }.should change{ Message.count }.by(1)


        message = Message.last
        message.from.should == sender.email
        message.user_id.should == sender.id
        message.subject.should == conversation.subject
        message.body_plain.should == complex_message_body
        message.message_id_header.should be_present

        project.members_who_get_email.each do |recipient|
          assert_queued(SendConversationMessageWorker, [{message_id: message.id, email_sender: true}])
        end

        Resque.run!

        ActionMailer::Base.deliveries.size.should == 5

        ActionMailer::Base.deliveries.each do |email|
          email.body.should include complex_message_body
          email.subject.should == "✔ [ucsd-el] #{conversation.subject}"
        end

      end
    end
  end

end
