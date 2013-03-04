require 'spec_helper'

describe EmailProcessor do
  context "when the project exists" do
    context "when the sender is a member of the project" do

      let(:project) { FactoryGirl.create(:conversation) }
      let(:to) { project.slug }
      let(:user) { FactoryGirl.create(:user)}
      let(:email) do
        FactoryGirl.build(
          :email,
          to: to,
          from: user.email,
          params: parent_message ? {
            headers: [
              "In-Reply-To: #{parent_message.message_id_header}",
              "References: <some-other-message-id@foo.com> #{parent_message.message_id_header}"
            ].join("\n")
          } : nil
        )
      end

      before do
        project.members << user
      end

      subject { EmailProcessor.process(email) }

      context "with an existing conversation" do
        let(:parent_message) { FactoryGirl.create(:message) }
        let(:project) { parent_message.conversation.project }

        context "with an in-reply-to" do
          context "when the message is sent to one list, but the in-reply-to point to a different list" do
            let(:other_project) { FactoryGirl.build(:project) }
            let(:to) { other_project.slug }

            xit "prioritizes the to address over the in-reply-to" do
              subject.conversation.project.should == other_project
            end
          end

          it "sets the conversation correctly" do
            subject.conversation.should == parent_message.conversation
          end

          it "sets the parent message correctly" do
            subject.parent_message.should == parent_message
          end

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
        end

        context "with references" do
          #check everything in the reply-to context
        end

        context "with in-reply-to and references" do
          # check everything in the reply-to context and also make sure the right one gets precedence
        end
      end

      context "outgoing mail" do
        it "creates outgoing mail jobs for all the users in the project except the sender"

        context "when creating the outgoing mail jobs fails" do
          it "does not create the message in the db when creating outgoing mail jobs fails"

          it "raises some error that makes griddler tell sendgrid to fuck off for a while"

        end
      end

    end

    context "when the project is specified via cc or bcc" do
      it "still identifies the project correctly"
    end

    context "when multiple projects are specified via cc or bcc" do
      it "should do something reasonable, but what?"
    end

    context "when the sender is not a member of the project" do
      it "sets the sender correctly"
    end
  end

  context "when the project doesn't exist" do
    it "bounces the message with a note about how the project doesn't exist"
  end
end
