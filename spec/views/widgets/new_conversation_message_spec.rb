require 'spec_helper'

describe "new_conversation_message" do

  let(:from){ double(:from, name: 'FROM NAME') }
  let(:organization){ double(:organization) }
  let(:message){ double(:message, class: Message, body: 'MESSAGE BODY', subject: 'MESSAGE SUBJECT') }
  let(:messages){ double(:messages, build: message) }
  let(:conversation){ double(:conversation, organization: organization, messages: messages) }
  let(:recipients) do
    2.times.map{|i|
      double(:recipient,
        name: "recipient #{i}",
        avatar_url: "/avatars/#{i}.jpg",
      )
    }
  end

  def locals
    {
      remote: true,
      url: '/conversations',
      from: from,
      organization: organization,
      message: message,
      conversation: conversation,
      recipients: recipients,
      show_subject: true,
      autofocus: true,
    }
  end

  describe "return_value" do
    subject{ return_value }
    it { should include 'MESSAGE SUBJECT' }
    it { should include 'MESSAGE BODY' }

  end

  describe "the subject field" do
    subject{ html.css('.subject_field') }

    context "when the show_subject option is true" do
      def locals
        super.merge(show_subject: true)
      end
      it { should be_present }
    end

    context "when the show_subject option is false" do
      def locals
        super.merge(show_subject: false)
      end
      it { should_not be_present }
    end
  end

  describe "the subject field" do
    subject{ html.css('.body_field') }
    it { should be_present }
  end

  describe "recipients" do
    it "should all be rendered as avatars" do
      recipients.each do |recipient|
        html.css(%(.avatar[title="#{recipient.name}"])).should be_present
        html.css(%(img[src="#{recipient.avatar_url}"])).should be_present
      end
    end
  end

end
