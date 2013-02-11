require 'spec_helper'

describe "conversation_metadata" do

  let(:conversation){ double(:conversation, subject: 'CONVERSATION SUBJECT') }
  def locals
    {conversation: conversation}
  end

  describe "return value" do
    subject{ return_value }
    it { should == "<h2>CONVERSATION SUBJECT</h2>\n" }
  end

end
