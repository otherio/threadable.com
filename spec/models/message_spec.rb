require 'spec_helper'

describe Message do
  it { should belong_to(:parent_message) }
  it { should belong_to(:conversation) }

  [:body_plain, :body_html, :stripped_plain, :stripped_html, :children, :message_id_header, :references_header, :reply, :subject, :from, :user, :parent_message].each do |attr|
    it { should allow_mass_assignment_of(attr) }
  end

  it "has a message id with a predictable domain (not some heroku crap hostname)" do
    subject.message_id_header.should =~ /^<.+\@multifyapp\.com>$/
  end

  context "with a parent message" do
    let(:parent_message) { FactoryGirl.create(:message, references_header: '<more-message-ids@foo.com>') }
    subject { Message.new(parent_message: parent_message) }

    it "inherits references from it parent message, and adds the parent's message id to references" do
      message = subject
      message.save
      message.references_header.should == [parent_message.references_header, parent_message.message_id_header].join(' ')
    end
  end

  describe "#body" do
    it "returns the plain text for now" do
      message = subject
      message.body.should == message.body_plain
    end
  end
end
