require 'spec_helper'

describe Covered::Message do

  let(:message){ covered.messages.latest }
  let(:recipient){ message.conversation.organization.members.all.last }
  subject{ message }

  it "knows if it has been sent to a given recipient" do
    expect( message.sent_to?(recipient) ).to be_false
    message.sent_to!(recipient)
    expect( message.sent_to?(recipient) ).to be_true
  end

end
