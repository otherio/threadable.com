require 'spec_helper'

describe Message do
  it { should belong_to(:parent_message) }
  it { should belong_to(:conversation) }

  let(:smtp_domain) { Rails.application.config.action_mailer.smtp_settings[:domain] }

  it "has a message id with a predictable domain (not some heroku crap hostname)" do
    subject.message_id_header.should =~ /^<.+\@#{smtp_domain}>$/
  end

  context "with a parent message" do
    let(:parent_message) { FactoryGirl.create(:message, references_header: '<more-message-ids@foo.com>') }
    subject(:message) { Message.new(parent_message: parent_message) }

    it "inherits references from it parent message, and adds the parent's message id to references" do
      message.save
      message.references_header.should == [parent_message.references_header, parent_message.message_id_header].join(' ')
    end

    it "detects the lack of an html part" do
      message.html?.should be_false
    end
  end

  context "with an html part" do
    subject(:message) { FactoryGirl.create(:message, body_html: 'foo', stripped_html: 'foo stripped') }

    it "detects the presence of an html part" do
      message.html?.should be_true
    end
  end

  describe "#body" do
    it "returns the plain text for now" do
      message = subject
      message.body.should == message.body_plain
    end
  end
end
