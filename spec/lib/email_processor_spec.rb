require 'spec_helper'

describe EmailProcessor do
  context "when the project exists" do
    context "when the sender is a member of the project" do

      let(:project) { FactoryGirl.create(:project) }
      let(:to) { project.slug }
      let(:user) { FactoryGirl.create(:user)}
      let(:headers) { nil }
      let(:email) do
        FactoryGirl.build(
          :email,
          to: to,
          from: user.email,
          params: { headers: headers }
        )
      end

      before do
        project.members << user
      end

      subject { EmailProcessor.process(email) }

      context "creating conversations and messages" do
        let(:parent_message) { FactoryGirl.create(:message) }
        let(:project) { parent_message.conversation.project }

        it "sets the sender user correctly" do
          subject.user.should == user
        end

        it "sets the from address correctly" do
          subject.from.should == email.from
        end

        it "makes a new message" do
          subject.should be_a(Message)
        end

        it "puts it in the db" do
          subject.should be_persisted
        end

        it "has a subject field" do
          subject.subject.should == email.subject
        end

        it "has a message body" do
          subject.body.should == email.body
        end

        it "sets the subject on the conversation" do
          subject.conversation.subject.should == email.subject
        end

        it "sets the conversation creator" do
          subject.conversation.creator.should == user
        end

        context "when the sender is not a member of the project" do
          it "bounces the mail until we make it do something better"
        end

        shared_examples_for :a_reply_in_a_thread do
          it "sets the conversation correctly" do
            subject.conversation.should == parent_message.conversation
          end

          it "sets the parent message correctly" do
            subject.parent_message.should == parent_message
          end

          context "when the message is sent to list A, but the replied-to message is in list B" do
            let(:other_project) { FactoryGirl.create(:project) }
            let!(:to) { other_project.slug }

            before do
              other_project.members << user
            end

            it "creates a new conversation in list A" do
              subject.conversation.project.should == other_project
            end
          end

          context "when the sender is not a member of the project" do
            it "sets the from address on the message correctly"

            it "adds the message to the thread"
          end
        end

        context "with an in-reply-to" do
          let(:headers) do
            [
              "In-Reply-To: #{parent_message.message_id_header}",
            ].join("\n")
          end

          it_behaves_like :a_reply_in_a_thread
        end

        context "with references" do
          let(:headers) do
            [
              "References: <some-other-message-id@foo.com> #{parent_message.message_id_header}"
            ].join("\n")
          end

          it_behaves_like :a_reply_in_a_thread
        end

        context "with in-reply-to and references" do
          let(:some_other_conversation) { FactoryGirl.create(:conversation, project: project)}
          let(:some_other_message) { FactoryGirl.create(:message, conversation: some_other_conversation) }
          let(:headers) do
            [
              "In-Reply-To: #{parent_message.message_id_header}",
              "References: <some-other-message-id@foo.com> #{some_other_message.message_id_header}"
            ].join("\n")
          end

          it_behaves_like :a_reply_in_a_thread
        end
      end

      context "outgoing mail" do
        let(:user2) { FactoryGirl.create(:user) }

        before do
          project.members << user2
          SendConversationMessageWorker.any_instance.stub(:enqueue)
        end

        it "enqueues emails for members" do
          SendConversationMessageWorker.should_receive(:enqueue).at_least(:once)
          subject
        end

        context "when creating the outgoing mail jobs fails" do
          it "does not create the message in the db"

          it "raises some error that makes griddler tell sendgrid to fuck off for a while"

        end
      end

    end

    context "when multiple projects are specified in the envelope" do
      it "iterates through the to addresses and processes each individually"
    end
  end

  context "when the project doesn't exist" do
    it "bounces the message with a note about how the project doesn't exist"
  end
end
