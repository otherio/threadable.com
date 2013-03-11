require "spec_helper"

describe ConversationMailer do
  let(:recipient_json) {JSON.parse(FactoryGirl.create(:user).to_json)}
  let(:sender) { FactoryGirl.create(:user) }
  let(:sender_json) {JSON.parse(sender.to_json)}
  let(:message) {FactoryGirl.create(:message, user: sender)}
  let(:message_json) {JSON.parse(message.to_json)}
  let(:parent_message_json) { nil }
  let(:project) { message.conversation.project }
  let(:conversation) { message.conversation }

  # this makes project_conversation_url work
  before do
    self.default_url_options[:host] = 'foo.com'

    @url_options_saved = ConversationMailer.default_url_options
    ConversationMailer.default_url_options = self.default_url_options
  end

  after do
    ConversationMailer.default_url_options = @url_options_saved
  end

  describe "#message" do
    subject do
      ConversationMailer.conversation_message(
        sender: sender_json,
        recipient: recipient_json,
        message: message_json,
        parent_message: parent_message_json,
        project: JSON.parse(project.to_json),
        conversation: JSON.parse(conversation.to_json),
        reply_to: 'the-reply-to-address'
      ).deliver
    end

    context "subject" do
      let(:subject_tag) { project.slug[0..7] }
      it "prepends the project's subject tag" do
        subject.subject.should == "[#{subject_tag}] #{message_json['subject']}"
      end

      context "with an existing subject tag" do
        let(:project) { FactoryGirl.create(:project) }
        let(:conversation) { FactoryGirl.create(:conversation) }
        let(:message) { FactoryGirl.create(:message, conversation: conversation, subject: "RE: Re: [#{subject_tag}] this is a subject") }

        it "does not prepend the subject tag twice" do
          subject.subject.should =~ /\[#{subject_tag}\]/
          subject.subject.should_not =~ /(\[#{subject_tag}\]).*\1/
        end
      end
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

    it "has a munged reply-to address" do
      project = message.conversation.project
      subject[:reply_to].inspect.should == 'the-reply-to-address'
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

    it "contains the message body" do
      subject.body.should include message_json['body']
    end

    context "with a host" do
      it "has a footer that links to the conversation" do
        subject.body.should include "View on Multify: #{project_conversation_url(project.slug, message.conversation.slug)}"
      end
    end

    describe "with parent messages" do
      let(:grandparent_message) {FactoryGirl.create(:message, user: sender)}
      let(:parent_message) {FactoryGirl.create(:message, user: sender, parent_message: grandparent_message, references_header: "<i am a references header> #{grandparent_message.message_id_header}")}
      let(:parent_message_json) { JSON.parse(parent_message.to_json) }
      let(:message) { FactoryGirl.create(:message, user: sender, parent_message: parent_message)}
      let(:message_json) { JSON.parse(message.to_json) }

      it "has correct (rfc 2822) in-reply-to" do
        # Mail strips the [<>] from these
        "<#{subject.in_reply_to}>".should == parent_message['message_id_header']
      end

      it "has correct references" do
        subject.to_s.should include "References:#{parent_message['references_header']} #{parent_message['message_id_header']}"
      end
    end
  end
end
