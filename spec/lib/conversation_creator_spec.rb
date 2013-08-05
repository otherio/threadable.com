require 'spec_helper'

describe ConversationCreator do

  let(:project){ double(:project) }
  let(:creator){ double(:creator) }
  let(:subject){ double(:subject) }
  let(:message){ double(:message) }


  let(:conversations){ double(:conversations) }
  let(:conversation){ double(:conversation) }
  let(:conversation_message){ double(:conversation_message, :persisted? => conversation_message_persisted) }

  before do
    expect(Conversation).to receive(:transaction).and_yield
    expect(project).to receive(:conversations).and_return(conversations)
    expect(conversations).to receive(:create!).with(
      creator: creator,
      subject: subject,
    ).and_return(conversation)

    expect(ConversationMessageCreator).to  \
      receive(:call). \
      with(creator, conversation, message). \
      and_return(conversation_message)
  end

  def call!
    ConversationCreator.call(project, creator, subject, message)
  end

  context "when the conversation message is persisted" do
    let(:conversation_message_persisted){ true }
    it "should return a conversation" do
      expect(call!).to eq conversation
    end
  end

  context "when the conversation message is not persisted" do
    let(:conversation_message_persisted){ false }
    it "should raise and ActiveRecord::Rollback exception" do
      expect{ call! }.to raise_error(ActiveRecord::Rollback)
    end
  end

end
