# Encoding: UTF-8
require 'spec_helper'

describe "email" do

  let(:complex_message_body){
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
  }

  before do
    ActionMailer::Base.stub(:default_url_options).and_return(host: 'example.com')
  end

  context "recieving from mailgun" do

    before do
      EmailProcessor::MailgunRequestToEmail.any_instance.stub(:authenticate).and_return(true)
    end

    def message_headers
      {
        'Message-Id' => '<3j4hjk35hk4h32423k@hackers.io>',

      }
    end

    # http://documentation.mailgun.net/user_manual.html#parsed-messages-parameters
    def params
      {
        'signature'        => 'THIS IS A FAKE SIGNATURE THAT WE STUB AROUND',
        'token'            => 'kashfjkhdjksahdjksadhjkasdhkjlashdjklashdjksa',
        'timestamp'        => 1.minute.ago.to_i,
        'message-headers'  => message_headers.to_a.to_json,
        'from'             => 'Alice Neilson <alice@ucsd.multifyapp.com>',
        'recipient'        => 'UCSD Electric Racing <ucsd-electric-racing@multifyapp.com>',
        'subject'          => 'this is the subject',
        'attachment-count' => '0',
        'body-html'        => '<div>'+complex_message_body+'</div>',
        'body-plain'       => complex_message_body,
        'stripped-html'    => '<div>'+complex_message_body+'</div>',
        'stripped-text'    => complex_message_body,
      }
    end

    it "should create a message" do
      post '/emails', params
      response.should be_success
      assert_queued ProcessEmailWorker
      ->{ Resque.run! }.should change{ Message.count }.by(1)
      message = Message.last
      message.from.should == "alice@ucsd.multifyapp.com"
      message.user.should == User.find_by_email("alice@ucsd.multifyapp.com")
      message.subject.should == params['subject']
      message.body.should == params['body-plain'].strip
      message.message_id_header.should == message_headers['Message-Id']
    end
  end

  context "recieving from the website" do

    let(:project) { Project.find_by_name("UCSD Electric Racing") }
    let(:user){ project.members.first }

    before do
      login_via_post_as user
    end

    context "replying to an existing conversation" do

      let(:conversation){ project.tasks.first }

      def params
        {message: {body: complex_message_body} }
      end

      it "should create a message send emails through mailgun" do
        ->{
          xhr :post, project_conversation_messages_path(project, conversation), params
          response.should be_success
        }.should change{ Message.count }.by(1)


        message = Message.last
        message.from.should == user.email
        message.user_id.should == user.id
        message.subject.should == conversation.subject
        message.body.should == complex_message_body
        message.message_id_header.should be_present

        project.members_who_get_email.each do |recipient|
          assert_queued(SendConversationMessageWorker, [{
            :project_id                => project.id,
            :project_slug              => project.slug,
            :conversation_slug         => message.conversation.slug,
            :is_a_task                 => message.conversation.task?,
            :message_subject           => message.subject,
            :sender_name               => message.user.name,
            :sender_email              => message.user.email,
            :recipient_id              => recipient.id,
            :recipient_name            => recipient.name,
            :recipient_email           => recipient.email,
            :message_body              => message.body,
            :message_message_id_header => message.message_id_header,
            :message_references_header => message.references_header,
            :parent_message_id_header  => message.parent_message.try(:message_id_header),
            :reply_to                  => project.formatted_email_address,
          }])
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
