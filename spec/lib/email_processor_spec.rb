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
          let(:conversation){ project.conversations.last }
          let(:parent_message){ conversation.messages.last }

          context "via the in-reply-to header" do
            def message_headers
              super.merge('In-Reply-To' => parent_message.message_id_header)
            end
            it_should_only_create_a_new_message_for_that_conversation!
          end

          context "via the references header" do
            def message_headers
              super.merge('References' => parent_message.message_id_header)
            end
            it_should_only_create_a_new_message_for_that_conversation!
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


#   context "when the project exists" do
#     context "when the sender is a member of the project" do

#       let(:project) { FactoryGirl.create(:project) }
#       let(:to) { project.slug }
#       let(:user) { FactoryGirl.create(:user)}
#       let(:headers) { nil }
#       let(:email) do
#         FactoryGirl.build(
#           :email,
#           to: to,
#           from: user.email,
#           params: { headers: headers }
#         )
#       end

#       before do
#         project.members << user
#       end

#       subject { EmailProcessor.process(email) }

#       context "creating conversations and messages" do
#         let(:parent_message) { FactoryGirl.create(:message) }
#         let(:project) { parent_message.conversation.project }

#         it "sets the sender user correctly" do
#           subject.user.should == user
#         end

#         it "sets the from address correctly" do
#           subject.from.should == email.from
#         end

#         it "makes a new message" do
#           subject.should be_a(Message)
#         end

#         it "puts it in the db" do
#           subject.should be_persisted
#         end

#         it "has a subject field" do
#           subject.subject.should == email.subject
#         end

#         it "has a message body" do
#           subject.body.should == email.body
#         end

#         it "sets the subject on the conversation" do
#           subject.conversation.subject.should == email.subject
#         end

#         it "sets the conversation creator" do
#           subject.conversation.creator.should == user
#         end

#         context "when the sender is not a member of the project" do
#           it "bounces the mail until we make it do something better"
#         end

#         shared_examples_for :a_reply_in_a_thread do
#           it "sets the conversation correctly" do
#             subject.conversation.should == parent_message.conversation
#           end

#           it "sets the parent message correctly" do
#             subject.parent_message.should == parent_message
#           end

#           context "when the message is sent to project A, but the replied-to message is in project B" do
#             let(:other_project) { FactoryGirl.create(:project) }
#             let!(:to) { other_project.slug }

#             before do
#               other_project.members << user
#             end

#             it "creates a new conversation in project A" do
#               subject.conversation.project.should == other_project
#             end
#           end

#           context "when the sender is not a member of the project" do
#             it "sets the from address on the message correctly"

#             it "adds the message to the thread"
#           end
#         end

#         context "with an in-reply-to" do
#           let(:headers) do
#             [
#               "In-Reply-To: #{parent_message.message_id_header}",
#             ].join("\n")
#           end

#           it_behaves_like :a_reply_in_a_thread
#         end

#         context "with references" do
#           let(:headers) do
#             [
#               "References: <some-other-message-id@foo.com> #{parent_message.message_id_header}"
#             ].join("\n")
#           end

#           it_behaves_like :a_reply_in_a_thread
#         end

#         context "with in-reply-to and references" do
#           let(:some_other_conversation) { FactoryGirl.create(:conversation, project: project)}
#           let(:some_other_message) { FactoryGirl.create(:message, conversation: some_other_conversation) }
#           let(:headers) do
#             [
#               "In-Reply-To: #{parent_message.message_id_header}",
#               "References: <some-other-message-id@foo.com> #{some_other_message.message_id_header}"
#             ].join("\n")
#           end

#           it_behaves_like :a_reply_in_a_thread
#         end
#       end

#       context "outgoing mail" do
#         let(:user2) { FactoryGirl.create(:user) }

#         before do
#           project.members << user2
#           SendConversationMessageWorker.any_instance.stub(:enqueue)
#         end

#         it "enqueues emails for members" do
#           SendConversationMessageWorker.should_receive(:enqueue).at_least(:once)
#           subject
#         end

#         context "when creating the outgoing mail jobs fails" do
#           it "does not create the message in the db"

#           it "raises some error that makes incoming! tell mailgun to fuck off for a while"

#         end
#       end

#     end

#     context "when multiple projects are specified in the envelope" do
#       it "iterates through the to addresses and processes each individually"
#     end
#   end

#   context "when the project doesn't exist" do
#     it "bounces the message with a note about how the project doesn't exist"
#   end
end
