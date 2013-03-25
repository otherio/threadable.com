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
      'recipient'        => 'UCSD Electric Racing <ucsd-electric-racing@multifyapp.com>',
      'subject'          => 'this is the subject',
      'attachment-count' => '0',
      'body-html'        => '<h1>This is the Body</h1>',
      'body-plain'       => 'This is the Body',
      'stripped-html'    => '<h1>This is the Body</h1>',
      'stripped-text'    => 'This is the Body',
    }
  end

  let(:request){ double(:request, params: params) }
  let(:request_processor){ double(:request_processor) }
  let(:email_as_a_string){ EmailProcessor::MailgunRequestToEmail.new(request).message }

  describe ".process_request" do

    before do
      EmailProcessor::MailgunRequestToEmail.should_receive(:new). \
        and_return(request_processor)

      request_processor.should_receive(:authenticate).at_least(:once). \
        and_return(authentication_result)
    end

    context "when authentication succeeds" do
      let(:authentication_result){ true }

      it "should take a request, create an email and schedule a ProcessEmailWorker job to process it" do
        email = double(:email)
        request_processor.should_receive(:message).and_return(email)
        email.should_receive(:to_s).and_return('EMAIL AS A STRING')
        ProcessEmailWorker.should_receive(:enqueue).with('EMAIL AS A STRING')
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
      instance = double(:instance)
      EmailProcessor.should_receive(:new).with(email).and_return(instance)
      instance.should_receive(:dispatch!)
      EmailProcessor.process_email(email)
    end
  end

  describe ".new" do

    subject{ EmailProcessor.new(email_as_a_string) }

    attr_reader :message

    describe "#dispatch!" do

      it "should pass the new message to MessageDispatch and call enqueue" do
        fake_message_dispatch = double(:fake_message_dispatch)
        MessageDispatch.should_receive(:new).with(subject.conversation_message).and_return(fake_message_dispatch)
        fake_message_dispatch.should_receive(:enqueue)
        subject.dispatch!
      end

    end

    describe "#conversation_message" do

      let(:message){ subject.conversation_message }

      let!(:conversation_count){ Conversation.count }
      let!(:message_count){ Message.count }

      let(:project){ Project.find_by_slug('ucsd-electric-racing') }
      let(:user   ){ User.find_by_email('alice@ucsd.multifyapp.com') }


      def validate_message!
        message.should be_a Message
        message.should be_persisted
        # message.subject.should == params['subject']

        message.body.should == params['stripped-text']
        message.user.should == user
        message.conversation.should be_persisted
        # message.conversation.subject.should == message.subject
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
