require 'spec_helper'

describe ConversationMessageCreator do

  let(:project) { Project.find_by_name("UCSD Electric Racing", include: :members) }

  let(:conversation) { project.conversations.first }

  let(:user) { project.members.first }

  def message_attributes
    {
      subject: "hey fellas",
      body: "Hey, <i>Anyone</i> want some <strong>cake</strong>?",
    }
  end

  it "should create a new conversation message and dispatch it for emailing" do
    message_dispatcher = double(:message_dispatcher)
    # MessageDispatch.should_receive(:new).with(kind_of(Message), email_sender: true).and_return(message_dispatcher)
    SendConversationMessageWorker.should_receive(:enqueue) #.with(message_id: 1)
    # message_dispatcher.should_receive(:enqueue)

    message = ConversationMessageCreator.call(user, conversation, message_attributes)
    message.should be_a Message
    message.should be_persisted
    message.subject.should        == message_attributes[:subject]
    message.body_html.should      == message_attributes[:body]
    message.stripped_html.should  == message_attributes[:body]
    message.body_plain.should     == strip_html(message_attributes[:body])
    message.stripped_plain.should == strip_html(message_attributes[:body])
    message.user.should           == user
    message.conversation.should   == conversation
  end

  def strip_html(html)
    HTMLEntities.new.decode Sanitize.clean(html.gsub(%r{<br/?>}, "\n"))
  end

end
