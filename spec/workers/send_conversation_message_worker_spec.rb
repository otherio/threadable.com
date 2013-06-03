require 'spec_helper'

describe SendConversationMessageWorker do

  let(:members){
    10.times.map{|i| double(:user, id: i) }
  }
  let(:user){ double(:user, id: 3) }
  let(:project){ double(:project, members_who_get_email: members) }
  let(:conversation){ double(:conversation, project: project) }
  let(:message){ double(:message, conversation: conversation, user: user) }
  let(:fake_email){ double(:fake_email) }

  it "sends the specified email" do
    Message.should_receive(:find).with(42).and_return(message)

    members.each do |user|
      email = double(:email)
      ConversationMailer.should_receive(:conversation_message).with(message, user).and_return(email)
      email.should_receive(:deliver)
    end

    SendConversationMessageWorker.perform(message_id: 42, email_sender: true)
  end

end
