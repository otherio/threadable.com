require 'spec_helper'

describe SendConversationMessageWorker do
  let(:recipient) {FactoryGirl.create(:user)}
  let(:sender) {FactoryGirl.create(:user)}
  let(:parent_message) {FactoryGirl.create(:message, user: sender)}
  let(:message) {FactoryGirl.create(:message, user: sender, parent_message: parent_message)}

  # this makes project_conversation_url work
  before do
    @url_options_saved = ConversationMailer.default_url_options
    ConversationMailer.default_url_options[:host] = 'foo.com'
  end

  after do
    ConversationMailer.default_url_options = @url_options_saved
  end

  it "sends the specified email" do
    SendConversationMessageWorker.perform(
      recipient: recipient,
      sender: sender,
      message: message,
      parent_message: parent_message,
      project: message.conversation.project,
      conversation: message.conversation,
      reply_to: 'foo@example.com'
    )
    ActionMailer::Base.deliveries.last.to.should == [recipient.email]
  end
end
