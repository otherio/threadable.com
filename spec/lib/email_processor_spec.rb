require 'spec_helper'

describe EmailProcessor do

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
      'recipient'        => recipient,
      'subject'          => 'this is the subject',
      'attachment-count' => '0',
      'body-html'        => body_html,
      'body-plain'       => body_plain,
      'stripped-html'    => stripped_html,
      'stripped-text'    => stripped_text,
    }
  end

  let(:request){ double(:request, params: params) }
  let(:request_processor){ double(:request_processor) }
  let(:stripped_request_processor){ double(:stripped_request_processor) }
  let(:email_as_a_string){ EmailProcessor::MailgunRequestToEmail.new(request).message }
  let(:stripped_email_as_a_string){ EmailProcessor::MailgunRequestToEmailStripped.new(request).message }
  let(:recipient) { 'UCSD Electric Racing <ucsd-electric-racing@multifyapp.com>' }
  let(:body_html) { "<div dir=3D\"ltr\">I am writing you back. Back! I write!</div><div class=3D\"g=\nmail_extra\"><br><br><div class=3D\"gmail_quote\">On Tue, Apr 2, 2013 at 10:51=\n AM, Nicole Aptekar <span dir=3D\"ltr\">&lt;<a href=3D\"mailto:nicoletbn@gmail=\n.com\" target=3D\"_blank\">nicoletbn@gmail.com</a>&gt;</span> wrote:<br>\n\n<blockquote class=3D\"gmail_quote\" style=3D\"margin:0 0 0 .8ex;border-left:1p=\nx #ccc solid;padding-left:1ex\"><div dir=3D\"ltr\">Sure~</div><div class=3D\"HO=\nEnZb\"><div class=3D\"h5\"><div class=3D\"gmail_extra\"><br><br><div class=3D\"gm=\nail_quote\">\n\nOn Tue, Apr 2, 2013 at 10:37 AM, ian <span dir=3D\"ltr\">&lt;<a href=3D\"mailt=\no:ian@sonic.net\" target=3D\"_blank\">ian@sonic.net</a>&gt;</span> wrote:<br>\n\n<blockquote class=3D\"gmail_quote\" style=3D\"margin:0 0 0 .8ex;border-left:1p=\nx #ccc solid;padding-left:1ex\">It&#39;s Tuesday. I have work lunch Wednesda=\ny, so I can take care of that thing. Also, want to grab food at 12:30?<span=\n><font color=3D\"#888888\"><div>\n\n\n\n<br></div><div>-Ian<span></span></div>\n</font></span></blockquote></div><br></div>\n</div></div></blockquote></div><br></div>" }
  let(:body_plain) {"Sorry I sent that blank mail. Shouldn't be possible in the future. derp.\n\n\nOn Sun, Apr 21, 2013 at 5:58 PM, Ian Baker <ian@sonic.net> wrote:\n\n> This is a response!\n>\n> So there!\n>\n> On Sunday, April 21, 2013, Nicole Aptekar wrote:\n>\n> > Another test. Mail back plz?\n> > _____\n> > View on Multify:\n> > http://beta.multifyapp.com/multify-testing/conversations/testing\n> > Unsubscribe:\n> >\n> http://beta.multifyapp.com/multify-testing/unsubscribe/jrFFF0z_f2O7M6K6eqPdf94=\n> >\n> >\n> _____\n> View on Multify:\n> http://beta.multifyapp.com/multify-testing/conversations/testing\n> Unsubscribe:\n> http://beta.multifyapp.com/multify-testing/unsubscribe/jrFFF0qqfzWrYOzqJ6Pdf90=\n>"}
  let(:stripped_html) { '<div dir=3D"ltr">I am writing you back. Back! I write!</div>' }
  let(:stripped_text) { 'I am writing you back. Back! I write!' }

  describe ".process_request" do

    before do
      EmailProcessor::MailgunRequestToEmail.should_receive(:new). \
        and_return(request_processor)

      request_processor.should_receive(:authenticate).at_least(:once). \
        and_return(authentication_result)
    end

    context "when authentication succeeds" do
      let(:authentication_result){ true }

      before do
        EmailProcessor::MailgunRequestToEmailStripped.should_receive(:new). \
          and_return(stripped_request_processor)
      end

      it "should take a request, create an email and schedule a ProcessEmailWorker job to process it" do
        email = double(:email)
        request_processor.should_receive(:message).and_return(email)
        email.should_receive(:to_s).and_return('EMAIL AS A STRING')

        stripped_email = double(:stripped_email)
        stripped_request_processor.should_receive(:message).and_return(stripped_email)
        stripped_email.should_receive(:to_s).and_return('STRIPPED')

        ProcessEmailWorker.should_receive(:enqueue).with('EMAIL AS A STRING', 'STRIPPED')
        EmailProcessor.process_request(request)
      end
    end

    context "when authentication fails" do
      let(:authentication_result){ false }
      it "should return false" do
        EmailProcessor.process_request(request).should be_false
      end
    end

  end

  describe ".process_email" do

    it "should create a new EmailProcessor instance and call dispatch!" do
      email = double(:email)
      stripped = double(:stripped)
      instance = double(:instance)
      EmailProcessor.should_receive(:new).with(email, stripped).and_return(instance)
      instance.should_receive(:dispatch!)
      EmailProcessor.process_email(email, stripped)
    end
  end

  describe ".new" do

    subject{ EmailProcessor.new(email_as_a_string, stripped_email_as_a_string) }

    attr_reader :message

    describe "#dispatch!" do
      it "should enqueue the message to be sent" do
        SendConversationMessageWorker.should_receive(:enqueue).with(message_id: subject.conversation_message.id)
        subject.dispatch!
      end
    end

    describe "#multify_project_slug" do
      subject{ EmailProcessor.new(email_as_a_string, stripped_email_as_a_string).multify_project_slug }

      context "with a recipient in a multify subdomain" do
        let(:recipient) { 'UCSD Electric Racing <ucsd-electric-racing@www-staging.multifyapp.com>' }

        it "returns the project slug even when using a subdomain" do
          subject.should == 'ucsd-electric-racing'
        end
      end

      context "with no multify project in the to field" do
        let(:recipient) { 'Some random guy <randomguy@example.com>' }

        it "raises an error" do
          expect { subject }.to raise_error
        end
      end
    end

    describe "#conversation_message" do

      def filter_token(body)
        body.gsub(%r{(https?://[\w\-\.]*multifyapp\.com/[\w\-\.]+/unsubscribe/)[^/]+}m, '\1')
      end

      let(:message){ subject.conversation_message }

      let!(:conversation_count){ Conversation.count }
      let!(:message_count){ Message.count }

      let(:project){ Project.find_by_slug('ucsd-electric-racing') }
      let(:user   ){ User.find_by_email('alice@ucsd.multifyapp.com') }

      def validate_message!
        message.should be_a Message
        message.should be_persisted
        message.subject.should == params['subject']

        message.body_plain.should == filter_token(params['body-plain'])
        message.body_html.should == filter_token(params['body-html'])
        message.stripped_plain.should == filter_token(params['stripped-text'])
        message.stripped_html.should == filter_token(params['stripped-html'])

        message.user.should == user
        message.conversation.should be_persisted
        message.conversation.project.should == project
      end

      def self.it_should_create_a_conversation_and_message!
        it "should create a conversation and message" do
          subject.conversation_message
          Conversation.count.should == conversation_count + 1
          Message.count.should == message_count + 1

          validate_message!
        end
      end

      def self.it_should_only_create_a_new_message_for_that_conversation!
        it "should create only a new message for that conversation" do
          subject.conversation_message
          Conversation.count.should == conversation_count
          Message.count.should == message_count + 1

          validate_message!
          message.conversation.should == conversation
          message.parent_message.should == parent_message
        end
      end

      context "when an unsubscribe token is present" do
        let(:body_plain) {"View on Multify:\n> > http://beta.multifyapp.com/multify-testing/conversations/tView on Multify:\n> http://beta.multifyapp.com/multify-testing/conversations/testing\n> Unsubscribe:\n> http://beta.multifyapp.com/multify-testing/unsubscribe/jrFFF0qqfzWrYOzqJ6Pdf90=\n>"}
        let(:body_html) {"View on Multify:\n> > http://beta.multifyapp.com/multify-testing/conversations/tView on Multify:\n http://beta.multifyapp.com/multify-testing/conversations/testing\n> Unsubscribe:\n> <a href=\"http://beta.multifyapp.com/multify-testing/unsubscribe/jrFFF0qqfzWrYOzqJ6Pdf90=\">\n"}
        let(:stripped_text) {"View on Multify:\n> > http://beta.multifyapp.com/multify-testing/conversations/tView on Multify:\n> http://beta.multifyapp.com/multify-testing/conversations/testing\n> Unsubscribe:\n> http://beta.multifyapp.com/multify-testing/unsubscribe/jrFFF0qqfzWrYOzqJ6Pdf90=\n>"}
        let(:body_html) {"View on Multify:\n> > http://beta.multifyapp.com/multify-testing/conversations/tView on Multify:\n http://beta.multifyapp.com/multify-testing/conversations/testing\n> Unsubscribe:\n> <a href=\"http://beta.multifyapp.com/multify-testing/unsubscribe/jrFFF0qqfzWrYOzqJ6Pdf90=\">\n"}

        it "should filter the token from the unsubscribe link" do
          subject.conversation_message
          message.body_plain.should_not =~ /jrFFF0qqfzWrYOzqJ6Pdf90/
          message.body_html.should_not =~ /jrFFF0qqfzWrYOzqJ6Pdf90/
          message.stripped_plain.should_not =~ /jrFFF0qqfzWrYOzqJ6Pdf90/
          message.stripped_html.should_not =~ /jrFFF0qqfzWrYOzqJ6Pdf90/
        end
      end

      context "when this message is not a reply" do
        it_should_create_a_conversation_and_message!
      end

      context "when this message is a reply" do
        context "to an unknown conversation" do

          context "via the in-reply-to header" do
            def message_headers
              super.merge('In-Reply-To' => 'whatnow@whoknows.fuck')
            end
            it_should_create_a_conversation_and_message!
          end

          context "via the references header" do
            def message_headers
              super.merge('References' => '<whatnow@whoknows.fuck>')
            end
            it_should_create_a_conversation_and_message!
          end

        end

        context "to an existing conversation" do
          let(:conversation){ project.conversations.where(subject: 'layup body carbon').first }
          let(:parent_message){ conversation.messages.first }

          context "via the in-reply-to header" do
            def message_headers
              super.merge('In-Reply-To' => parent_message.message_id_header)
            end
            it_should_only_create_a_new_message_for_that_conversation!
          end

          context "via the references header" do
            context "at the end" do
              def message_headers
                super.merge('References' => "<someid@someplace.what> #{parent_message.message_id_header}")
              end
              it_should_only_create_a_new_message_for_that_conversation!
            end

            context "not at the end" do
              def message_headers
                super.merge('References' => "<someid@someplace.what> #{parent_message.message_id_header} <whatnow@whoknows.fuck>")
              end
              it_should_only_create_a_new_message_for_that_conversation!
            end
          end


          context "via both the in-reply-to header and the references header" do
            def message_headers
              super.merge(
                'In-Reply-To' => parent_message.message_id_header,
                'References'  => '<o67opo7p567op67op@xxxcams.lol>',
              )
            end
            it_should_only_create_a_new_message_for_that_conversation!
          end

        end

        context "to a message of another project" do
          let(:conversation){ project.conversations.last }
          let(:parent_message){ FactoryGirl.create(:message) }

          before do
            parent_message.conversation.project.members << user
            __memoized[:conversation_count] = Conversation.count
            __memoized[:message_count] = Message.count
          end

          def message_headers
            super.merge('In-Reply-To' => parent_message.message_id_header)
          end

          it_should_create_a_conversation_and_message!

        end
      end
    end
  end
end
