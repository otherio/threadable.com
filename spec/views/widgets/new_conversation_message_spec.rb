require 'spec_helper'

describe "new_conversation_message" do

  let(:from){ double(:from, name: 'FROM NAME') }
  let(:project){ double(:project) }
  let(:message){ double(:message, class: Message, body: 'MESSAGE BODY', subject: 'MESSAGE SUBJECT') }
  let(:messages){ double(:messages, build: message) }
  let(:conversation){ double(:conversation, project: project, messages: messages) }

  def locals
    {
      remote: true,
      url: '/conversations',
      from: from,
      project: project,
      message: message,
      conversation: conversation,
      show_subject: true,
      autofocus: true,
    }
  end

  describe "return_value" do
    subject{ return_value }
    it { should include 'MESSAGE SUBJECT' }
    it { should include 'MESSAGE BODY' }
  end

end
