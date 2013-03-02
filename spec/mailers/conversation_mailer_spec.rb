require "spec_helper"

describe ConversationMailer do
  let(:recipient_json) {JSON.parse(FactoryGirl.create(:user).to_json)}
  let(:sender) { FactoryGirl.create(:user) }
  let(:sender_json) {JSON.parse(sender.to_json)}
  let(:message) {FactoryGirl.create(:message, user: sender)}
  let(:message_json) {JSON.parse(message.to_json)}
  let(:parent_message_json) { nil }

  describe "#message" do
    subject do
      ConversationMailer.conversation_message(
        sender: sender_json,
        recipient: recipient_json,
        message: message_json,
        parent_message: parent_message_json
      ).deliver
    end

    it "has the correct subject line" do
      subject.subject.should == message_json['subject']
    end

    it "has its headers in the correct case" do
      text = subject.to_s
      text.should =~ /In-Reply-To:/
      text.should =~ /References:/
      text.should =~ /Message-ID:/
    end

    it "has the correct sender address" do
      subject[:from].inspect.should include(sender_json['name'], "<#{sender_json['email']}>")
    end

    it "has the correct recipient address" do
      subject[:to].inspect.should include(recipient_json['name'], "<#{recipient_json['email']}>")
    end

    it "has correct references and in-reply-to headers" do
      subject.in_reply_to.should be_nil
      subject.references.should be_nil
    end

    it "has the correct message id" do
      # Mail strips the [<>] from these
      "<#{subject.message_id}>".should == message_json['message_id_header']
    end

    it "contains a message body" do
      subject.body.should == message_json['body']
    end

    describe "with parent messages" do
      let(:grandparent_message) {FactoryGirl.create(:message, user: sender)}
      let(:parent_message) {FactoryGirl.create(:message, user: sender, parent_message: grandparent_message, references_header: "<i am a references header> #{grandparent_message.message_id_header}")}
      let(:parent_message_json) { JSON.parse(parent_message.to_json) }
      let(:message) {FactoryGirl.create(:message, user: sender, parent_message: parent_message)}
      let(:message_json) { JSON.parse(message.to_json) }

      it "has correct (rfc 2822) in-reply-to" do
        # Mail strips the [<>] from these
        "<#{subject.in_reply_to}>".should == parent_message['message_id_header']
      end

      it "has correct references" do
        subject.references.should == "#{parent_message['references_header']} #{parent_message['message_id_header']}"
      end
    end
  end
end
