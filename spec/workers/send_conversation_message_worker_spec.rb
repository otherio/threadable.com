require 'spec_helper'

describe SendConversationMessageWorker do

  let(:memberships){
    10.times.map{|i| double(:project_membership, user: double(:user, id: i)) }
  }
  let(:user){ memberships[3].user }
  let(:project){ double(:project) }
  let(:conversation){ double(:conversation, project: project) }
  let(:message){ double(:message, conversation: conversation, user: user) }
  let(:fake_email){ double(:fake_email) }

  before do
    Message.should_receive(:find).with(42).and_return(message)
    memberships_scope = double(:memberships_scope)
    expect(project          ).to receive(:memberships         ).and_return(memberships_scope)
    expect(memberships_scope).to receive(:that_get_email      ).and_return(memberships_scope)
    expect(memberships_scope).to receive(:includes).with(:user).and_return(memberships.dup)
  end

  context "when email_sender:true is sent" do
    it "sends the conversation message via email to each project member who recieves emails" do
      memberships.each do |membership|
        email = double(:email)
        ConversationMailer.should_receive(:conversation_message).with(message, membership).and_return(email)
        email.should_receive(:deliver)
      end
      SendConversationMessageWorker.perform(message_id: 42, email_sender: true)
    end
  end

  context "when email_sender: false is sent" do
    it "sends the conversation message to each project member except the sender" do
      memberships.each do |membership|
        next if membership.user == user
        email = double(:email)
        ConversationMailer.should_receive(:conversation_message).with(message, membership).and_return(email)
        email.should_receive(:deliver)
      end
      SendConversationMessageWorker.perform(message_id: 42, email_sender: false)
    end
  end

end
