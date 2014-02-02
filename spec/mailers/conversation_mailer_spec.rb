# encoding: utf-8
require "spec_helper"

describe ConversationMailer do
  describe "conversation_message" do

    signed_in_as 'bethany@ucsd.example.com'

    let(:organization){ current_user.organizations.find_by_slug! 'raceteam' }
    let(:conversation){ organization.conversations.find_by_slug! 'layup-body-carbon' }
    let(:message){ conversation.messages.latest }
    let(:recipient){ organization.members.all.last }

    let(:mail){ ConversationMailer.new(threadable).generate(:conversation_message, organization, message, recipient) }
    let(:email){ RSpec::Support::SentEmail::Email.new(mail) }

    let(:expected_to           ){ organization.task_email_address }
    let(:expected_cc           ){ '' }
    let(:expected_from         ){ message.from }
    let(:expected_envelope_to  ){ recipient.email_address }
    let(:expected_envelope_from){ organization.task_email_address }
    let(:expected_html_part    ){ message.body_html.gsub(/\n/,'') }

    let(:mail_as_string){ mail.to_s }
    let(:text_part){ mail.text_part.body.to_s }
    let(:html_part){ mail.html_part.body.to_s }

    def validate_mail!
      mail.subject.should include "[RaceTeam]"
      mail.subject.should include conversation.subject
      mail.subject.scan('RaceTeam').size.should == 1

      mail.to.should                    == [expected_to]
      mail.header['From'].to_s.should   == expected_from
      mail.smtp_envelope_to.should      == [expected_envelope_to]
      mail.smtp_envelope_from.should    == expected_envelope_from

      mail_as_string.should =~ /In-Reply-To:/
      mail_as_string.should =~ /References:/
      mail_as_string.should =~ /Message-ID:/

      text_part.should include message.body_plain
      html_part.gsub(/\n/,'').should include expected_html_part
      text_part.should include "View on Threadable:\n#{conversation_url(organization, 'my', conversation)}"

      organization_unsubscribe_token = extract_organization_unsubscribe_token(text_part)
      expect( OrganizationUnsubscribeToken.decrypt(organization_unsubscribe_token) ).to eq [organization.id, recipient.id]

      expect(email.link('feedback')).to be_present
      expect(email.link('feedback')[:href]).to eq "mailto:support@127.0.0.1"

      expect(text_part).to include "mailto:#{organization.task_email_address}"

      expect(mail.header[:'Reply-To'].to_s).to eq organization.formatted_task_email_address
      expect(mail.header[:'List-ID'].to_s ).to eq conversation.list_id
      expect(mail.header[:'Cc'].to_s      ).to eq expected_cc
      expect(mail.in_reply_to             ).to eq message.parent_message.message_id_header[1..-2]
      expect(mail.message_id              ).to eq message.message_id_header[1..-2]
      expect(mail.references              ).to eq(
        message.parent_message.references_header.scan(/<(.+?)>/).flatten +
        [message.parent_message.message_id_header[1..-2]]
      )
    end

    it "returns a mail message as expected" do
      validate_mail!
    end

    context "when the subject is a reply" do
      it "should parse and construct the correct subject" do
        message.stub(subject: "RE: Re: [RaceTeam] #{conversation.subject}")
        validate_mail!
      end

      context "with a stylesheet link tag in the body" do
        let(:expected_html_part) { 'so identifiable' }
        before do
          message.update(body_html: "<html><head><link rel=\"stylesheet\" href=\"/zimbra/css/msgview.css?v=201306050001\"></head><body>so identifiable</body></html>")
        end

        it "should return a mail message without choking on Roadie" do
          validate_mail!
          mail.html_part.body.to_s.should_not include 'zimbra/css/msgview.css'
        end
      end
    end

    context "when we send a message to the message creator" do
      let(:recipient){ message.creator }
      it "should set the from address as the organization instead of the sender" do
        validate_mail!
      end
    end

    context "when given a message without a user" do
      let(:expected_cc) { message.from }
      before do
        message.stub(creator: nil)
      end

      it "should set the from address to the incoming messages's from address" do
        validate_mail!
      end
    end

    context "message summary" do
      let(:body){
        %(Everybody, yeah Rock your body, yeah Everybody, yeah Rock your body right Backstreet's )+
        %(back, alright Hey, yeah Oh my God, we're back again Brothers, sisters, everybody sing )+
        %(Gonna bring the flavor, show you how Gotta question for you better answer now, yeah)
      }
      let(:body_double){ double(:body, html?: false, html_safe?: false, to_s: body, length: body.length) }
      before{
        message.stub body: body_double
        message.stub body_plain: body_double
      }
      it "returns the first bunch of characters of the summary" do
        mail.html_part.body.to_s.should include "#{message.body.to_s[0,200]}"
      end

      context "with a short message" do
        let(:body){ "Everybody, please." }
        it "pads the remaining characters with spaces and then periods when the message is short" do
          mail.html_part.body.to_s.should include "Everybody, please.#{' '*82}#{'_'*82}"
        end
      end
    end

  end
end
