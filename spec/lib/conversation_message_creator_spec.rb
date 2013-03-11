require 'spec_helper'

describe ConversationMessageCreator do

  let(:project) { Project.find_by_name("UCSD Electric Racing", include: :members) }

  let(:conversation) { project.conversations.first }

  let(:user) { project.members.first }

  let(:message_attributes) {
    {
      subject: "hey fellas",
      body: "anyone want some cake?",
    }
  }

  before do
  end

  it "should create a new conversation message and dispatch it for emailing" do
    message_dispatcher = double(:message_dispatcher)
    MessageDispatch.should_receive(:new).with(kind_of(Message)).and_return(message_dispatcher)
    message_dispatcher.should_receive(:enqueue)

    message = ConversationMessageCreator.call(user, conversation, message_attributes)
    message.should be_a Message
    message.should be_persisted
    message.subject.should == message_attributes[:subject]
    message.body.should == message_attributes[:body]
    message.user.should == user
    message.conversation.should == conversation
  end

end
