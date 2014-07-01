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

    let(:expected_to           ){ [organization.task_email_address] }
    let(:expected_cc           ){ '' }
    let(:expected_from         ){ message.from }
    let(:expected_envelope_to  ){ recipient.email_address }
    let(:expected_envelope_from){ organization.task_email_address }
    let(:expected_html_part    ){ message.body_html.gsub(/\n/,'') }
    let(:expected_reply_to     ){ organization.formatted_task_email_address }

    let(:mail_as_string){ mail.to_s }
    let(:text_part){ mail.text_part.body.to_s }
    let(:html_part){ mail.html_part.body.to_s }

    let(:dmarc_verified) { true }

    before do
      VerifyDmarc.stub(:call).and_return(dmarc_verified)
    end

    def validate_mail!
      mail.subject.should include "[RaceTeam]"
      mail.subject.should include conversation.subject
      mail.subject.scan('RaceTeam').size.should == 1

      mail.to.should                    match_array expected_to
      mail.header['From'].to_s.should   == expected_from
      mail.smtp_envelope_to.should      == [expected_envelope_to]
      mail.smtp_envelope_from.should    == expected_envelope_from

      mail_as_string.should =~ /In-Reply-To:/
      mail_as_string.should =~ /References:/
      mail_as_string.should =~ /Message-ID:/

      text_part.should include message.body_plain
      html_part.gsub(/\n/,'').should include expected_html_part
      text_part.should include "Web view:\n#{conversation_url(organization, 'my', conversation)}"

      organization_unsubscribe_token = extract_organization_unsubscribe_token(text_part)
      expect( OrganizationUnsubscribeToken.decrypt(organization_unsubscribe_token) ).to eq [organization.id, recipient.id]

      expect(email.link('feedback')).to be_present
      expect(email.link('feedback')[:href]).to eq "mailto:support@localhost"

      conversation.groups.all.each do |group|
        expect(text_part).to include group.email_address
      end

      expect(mail.header[:'Reply-To'].to_s.split(/,\s*/)).to match_array expected_reply_to.split(/,\s*/)

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

    context "when reply-to munging is disabled" do
      before do
        recipient.update(munge_reply_to: false)
      end
      let(:expected_reply_to) { '' }
      it "should set the from address as the organization instead of the sender" do
        validate_mail!
      end
    end

    context 'when the conversation is in multiple groups' do
      let(:expected_reply_to) { 'UCSD Electric Racing Tasks <raceteam+task@raceteam.localhost>, "UCSD Electric Racing: Fundraising Tasks" <fundraising+task@raceteam.localhost>' }
      let(:fundraising) { organization.groups.find_by_slug('fundraising') }
      let(:expected_to           ){ conversation.email_addresses }

      before do
        conversation.groups.add fundraising
      end

      it "puts both groups in the reply-to" do
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

    context "with a from address domain that has a restrictive DMARC policy" do
      let(:dmarc_verified) { false }

      context 'with reply-to munging enabled' do
        let(:expected_cc  ){ message.from }
        let(:expected_from){ 'Tom Canver via Threadable <placeholder@localhost>' }

        it "rewrites from, and adds from to cc" do
          validate_mail!
        end
      end

      context 'with reply-to munging disabled' do
        let(:expected_from    ){ 'Tom Canver via Threadable <placeholder@localhost>' }
        let(:expected_reply_to) { message.from }

        before do
          recipient.update(munge_reply_to: false)
        end

        it "rewrites from, adds from to reply-to" do
          validate_mail!
        end
      end
    end

    describe "message summary" do
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

    describe "mail buttons" do
      context "with mail buttons enabled" do
        it "has the buttons in the mail" do
          mail.html_part.body.to_s.should include 'class="threadable-button"'
          mail.html_part.body.to_s.should_not include 'class="threadable-conversation"'
        end
      end
      context "with mail buttons disabled" do
        before do
          recipient.update(show_mail_buttons: false)
        end
        it "doesn't have buttons in the mail" do
          mail.html_part.body.to_s.should_not include 'class="threadable-button"'
          mail.html_part.body.to_s.should include 'class="threadable-conversation"'
        end
      end
    end

    context 'with attachments' do
      let(:conversation) { organization.conversations.find_by_slug! 'how-are-we-paying-for-the-motor-controller' }

      it 're-attaches the attachments with correct metadata' do
        expect(mail.attachments.length).to eq 3
        attachment = mail.attachments.find { |attachment| attachment.filename == 'some.jpg' }

        expect(attachment.mime_type).to eq 'image/jpeg'
        expect(attachment.content_id).to eq '<somejpgcontentid>'
        expect(attachment.header['X-Attachment-Id'].value).to eq 'somejpgcontentid'
      end
    end

  end
end
