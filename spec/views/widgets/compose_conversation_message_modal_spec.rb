require 'spec_helper'

describe "compose_conversation_message_modal" do

  let(:conversation){ double(:conversation) }

  def locals
    {conversation: conversation}
  end

  before do
    expect(view).to receive(:render_widget).
      with(:new_conversation_message, conversation, remote: true).
      and_return('NEW CONVERSATION MESSAGE HTML')
  end

  it "should just render the new_conversation_message widget" do
    expect(return_value).to eq "NEW CONVERSATION MESSAGE HTML\n"
  end

end
