require "spec_helper"

describe ConversationMailer do
  describe "conversation_message" do

    before do
      default_url_options[:host] = 'multifyapp.com'
      described_class.default_url_options[:host] = 'multifyapp.com'
    end
    after do
      described_class.default_url_options.delete(:host)
    end

    let(:project){ Project.find_by_name('UCSD Electric Racing') }

    let(:conversation){ project.conversations.find_by_subject('layup body carbon') }

    let(:parent_message){ conversation.messages.last }

    let(:references){
      %W(
        <j34h2jkh423jk4h32jk4h23jk42jk3h4@somewhere.io>
        <ovcbivcb0vc9v09v0b9bv0bv0@anotherpla.ce>
      )
    }

    let(:message){
      conversation.messages.new(
        user: project.members.first,
        subject: conversation.subject,
        body: 'This is the best project everz.',
        parent_message: parent_message,
        references_header: references.join(" ")
      )
    }

    let(:reply_to){ 'foo@example.com' }

    let(:recipient){ project.members.last }

    def data
      {
        :project_id                => project.id,
        :project_slug              => project.slug,
        :conversation_slug         => conversation.slug,
        :message_subject           => message.subject,
        :sender_name               => message.user.name,
        :sender_email              => message.user.email,
        :recipient_id              => recipient.id,
        :recipient_name            => recipient.name,
        :recipient_email           => recipient.email,
        :message_body              => message.body,
        :message_message_id_header => message.message_id_header,
        :message_references_header => message.references_header,
        :parent_message_id_header  => message.parent_message.message_id_header,
        :reply_to                  => reply_to,
      }
    end

    subject(:mail) { ConversationMailer.conversation_message(data) }

    let(:mail_headers){
      Hash[mail.header_fields.map{|hf| [hf.name, hf.value] }]
    }
    let(:mail_as_text){ mail.to_s }

    def validate_mail!
      mail.subject.should include "[ucsd-el] #{conversation.subject}"
      mail.subject.scan('ucsd-el').size.should == 1
      mail.to.should == [recipient.email]
      mail.from.should == [message.user.email]

      mail_as_text.should =~ /In-Reply-To:/
      mail_as_text.should =~ /References:/
      mail_as_text.should =~ /Message-ID:/
      mail_as_text.should include 'This is the best project everz.'
      mail_as_text.should include "View on Multify: #{project_conversation_url(project, conversation)}"
      mail_as_text =~ /multifyapp\.com\/#{Regexp.escape(project.slug)}\/unsubscribe\/(\S+)/

      unsubscribe_token = $1
      unsubscribe_token.should_not be_blank
      unsubscribe_token = URI.decode(unsubscribe_token)
      UnsubscribeToken.decrypt(unsubscribe_token).should == [project.id, recipient.id]

      mail.reply_to.should == [reply_to]
      mail.in_reply_to.should == message.parent_message.message_id_header[1..-2]
      mail.message_id.should == message.message_id_header[1..-2]
      mail.references.should == references.map{|r| r[1..-2] }
    end

    it "returns a mail message as expected" do
      validate_mail!
    end

    context "when the subject is a reply" do
      def data
        super.merge(
          :message_subject => "RE: Re: [ucsd-el] #{conversation.subject}",
        )
      end
      it "should parse and construct the correct subject" do
        validate_mail!
      end
    end

  end

end
