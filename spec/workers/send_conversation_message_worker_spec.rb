require 'spec_helper'

describe SendConversationMessageWorker do

  let(:fake_email){ double(:fake_email) }

  it "sends the specified email" do
    ConversationMailer.should_receive(:conversation_message).with(these: 'are fake param').and_return(fake_email)
    fake_email.should_receive(:deliver)
    SendConversationMessageWorker.perform('these'=>'are fake param')
  end

end
