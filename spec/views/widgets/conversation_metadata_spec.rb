require 'spec_helper'

describe "conversation_metadata" do

  let(:conversation){ double(:conversation, subject: 'CONVERSATION SUBJECT', organization: double(:organization), muted?: false ) }
  def locals
    {conversation: conversation}
  end

  describe "return value" do
    subject{ return_value }
    it { should include "CONVERSATION SUBJECT" }
  end

end
