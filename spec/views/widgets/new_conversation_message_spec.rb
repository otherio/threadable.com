require 'spec_helper'

describe "new_conversation_message" do

  let(:from){ double(:from, name: 'FROM NAME') }
  let(:project){ double(:project) }
  let(:message){ double(:message, body: 'MESSAGE BODY') }
  let(:messages){ double(:messages, build: message) }
  let(:conversation){ double(:conversation, project: project, messages: messages) }

  def locals
    {
      from: from,
      conversation: conversation,
    }
  end

  describe "return_value" do
    subject{ return_value }
    it { should include 'From: FROM NAME' }
    it { should include 'MESSAGE BODY' }
  end

end
