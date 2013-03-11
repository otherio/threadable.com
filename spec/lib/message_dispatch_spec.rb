require 'spec_helper'

describe MessageDispatch do
  context "sending a message" do
    let(:user2) { FactoryGirl.create(:user) }
    let(:message) { FactoryGirl.create(:message) }
    let(:user) { message.user }
    let(:project) { message.conversation.project }

    before do
      project.members << [user, user2]
      SendConversationMessageWorker.any_instance.stub(:enqueue)
    end

    subject { MessageDispatch.new(message).enqueue }

    it "enqueues emails for members" do
      SendConversationMessageWorker.should_receive(:enqueue).with(
        sender: message.user,
        recipient: anything,
        message: message,
        parent_message: message.parent_message,
        project: project,
        conversation: message.conversation,
        reply_to: anything
      ).exactly(project.members.length - 1).times
      subject
    end

    it "does not send mail to the current user" do
      SendConversationMessageWorker.should_not_receive(:enqueue).with(
        sender: anything,
        recipient: user,
        message: anything,
        parent_message: anything,
        project: anything,
        conversation: anything,
        reply_to: anything
      )
      subject
    end
  end
end
