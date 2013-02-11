require 'spec_helper'

describe "conversation_messages" do

  let(:messages){ 2.times.map{|i| double(:"message#{i}") } }
  let(:conversation){ double(:conversation, messages: messages) }
  let(:from){ double(:from) }

  def locals
    {conversation: conversation, from: from}
  end

  before do
    messages.each_with_index do |message, index|
      view.should_receive(:render_widget).
        with(:message, message).
        and_return("message #{index}")
    end
    view.should_receive(:render_widget).
      with(:new_conversation_message, conversation, from: from).
      and_return('NEW CONVERSATION WIDGET')
  end

  it "should return a list of messages and a new conversation form at the bottom" do
    html.css('ol.messages > li').map(&:text).should == ["message 0","message 1"]
    html.text.should include 'NEW CONVERSATION WIDGET'
  end

  describe "return value" do
    subject{ return_value }
    it { should be_a String}
  end

end
