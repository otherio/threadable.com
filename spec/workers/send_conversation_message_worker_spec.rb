require 'spec_helper'

describe SendConversationMessageWorker do
  let(:recipient) {FactoryGirl.create(:user)}
  let(:sender) {FactoryGirl.create(:user)}
  let(:parent_message) {FactoryGirl.create(:message, user: sender)}
  let(:message) {FactoryGirl.create(:message, user: sender, parent_message: parent_message)}

  it "sends the specified email" do
    SendConversationMessageWorker.perform(
      recipient: recipient,
      sender: sender,
      message: message,
      parent_message: parent_message
    )
    ActionMailer::Base.deliveries.last.to.should == [recipient.email]
  end
end
