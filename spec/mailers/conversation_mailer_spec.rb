# encoding: utf-8
require "spec_helper"

describe ConversationMailer, :type => :mailer do
  describe "conversation_message" do

    signed_in_as 'bethany@ucsd.example.com'

    let(:organization){ current_user.organizations.find_by_slug! 'raceteam' }
    let(:conversation){ organization.conversations.find_by_slug! 'layup-body-carbon' }
    let(:message){ conversation.messages.latest }
    let(:recipient){ organization.members.find_by_email_address('nadya@ucsd.example.com') }

    let(:mail){ ConversationMailer.new(threadable).generate(:conversation_message, organization, message, recipient) }
    let(:email){ RSpec::Support::SentEmail::Email.new(mail) }

    let(:expected_to           ){ [organization.task_email_address] }
    let(:expected_cc           ){ '' }
    let(:expected_from         ){ message.from }
    let(:expected_envelope_to  ){ recipient.email_address }
    let(:expected_envelope_from){ organization.task_email_address }
    let(:expected_html_part    ){ message.body_html.gsub(/\n/,'') }
    let(:expected_reply_to     ){ organization.formatted_task_email_address }
    let(:expect_reply          ){ true }

    let(:mail_as_string){ mail.to_s }
    let(:text_part){ mail.text_part.body.to_s }
    let(:html_part){ mail.html_part.body.to_s }

    let(:dmarc_verified) { true }

    before do
      allow(VerifyDmarc).to receive(:call).and_return(dmarc_verified)
    end

    def validate_mail!
      expect(mail.subject).to include "[RaceTeam]"
      expect(mail.subject).to include conversation.subject
      expect(mail.subject.scan('RaceTeam').size).to eq(1)

      expect(mail.to).to                    match_array expected_to
      expect(mail.header['From'].to_s).to   eq(expected_from)
      expect(mail.smtp_envelope_to).to      eq([expected_envelope_to])
      expect(mail.smtp_envelope_from).to    eq(expected_envelope_from)

      if expect_reply
        expect(mail_as_string).to match(/In-Reply-To:/)
        expect(mail_as_string).to match(/References:/)
        expect(mail.in_reply_to).to eq message.parent_message.message_id_header[1..-2]
        expect(mail.references              ).to eq(
          message.parent_message.references_header.scan(/<(.+?)>/).flatten +
          [message.parent_message.message_id_header[1..-2]]
        )
      end

      expect(mail_as_string).to match(/Message-ID:/)

      expect(text_part).to include message.body_plain
      expect(html_part.gsub(/\n/,'')).to include expected_html_part
      expect(text_part).to include "Web view:\n#{conversation_url(organization, 'my', conversation)}"

      organization_unsubscribe_token = extract_organization_unsubscribe_token(text_part)
      expect( OrganizationUnsubscribeToken.decrypt(organization_unsubscribe_token) ).to eq [organization.id, recipient.id]

      expect(email.html_part.to_s).to include 'DOCTYPE'

      expect(email.link('feedback')).to be_present
      expect(email.link('feedback')[:href]).to eq "mailto:support@localhost"

      # check to make sure roadie inlined styles
      expect(email.html_part.body).to include 'style="font-family:sans-serif;text-decoration:none;font-size:11px;font-weight:300;"'

      conversation.groups.all.each do |group|
        expect(text_part).to include group.email_address
      end

      expect(mail.header[:'Reply-To'].to_s.split(/,\s*/)).to match_array expected_reply_to.split(/,\s*/)

      expect(mail.header[:'List-ID'].to_s ).to eq conversation.list_id
      expect(mail.header[:'Cc'].to_s      ).to eq expected_cc
      expect(mail.message_id              ).to eq message.message_id_header[1..-2]
    end

    it "returns a mail message as expected" do
      validate_mail!
    end

    context 'with a custom domain' do
      let(:email_domain) { organization.email_domains.find_by_domain('raceteam.com') }
      let(:expected_to         ){ ['raceteam+task@raceteam.com'] }
      signed_in_as 'alice@ucsd.example.com'

      before do
        email_domain.outgoing!
      end

      it "inserts the custom domain in the To: header, but not the envelope" do
        validate_mail!
      end
    end

    context "when the subject is a reply" do
      it "should parse and construct the correct subject" do
        allow(message).to receive_messages(subject: "RE: Re: [RaceTeam] #{conversation.subject}")
        validate_mail!
      end

      context "with a stylesheet link tag in the body" do
        let(:expected_html_part) { 'so identifiable' }
        before do
          message.update(body_html: "<html><head><link rel=\"stylesheet\" href=\"/zimbra/css/msgview.css?v=201306050001\"></head><body>so identifiable</body></html>")
        end

        it "should succeed, and remove the incorrect stylesheet tag" do
          validate_mail!
          expect(mail.html_part.body.to_s).not_to include 'zimbra/css/msgview.css'
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
        allow(message).to receive_messages(creator: nil)
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

        context 'when the user has a comma in their name' do
          let(:expected_from){ '"Canver, Thomas via Threadable" <placeholder@localhost>' }

          before do
            message.message_record.update_attributes(from: '"Canver, Thomas" <tom@ucsd.example.com>')
          end

          it 'properly quotes the rewritten name' do
            validate_mail!
          end
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

    context 'follow and mute' do
      let(:html) { mail.html_part.body.to_s }
      before do
        validate_mail!
      end

      context 'with no followers or muters' do
        let(:conversation){ organization.conversations.find_by_slug! 'inventory-led-supplies' }
        let(:expected_to) { ["electronics+task@raceteam.localhost", "fundraising+task@raceteam.localhost", "graphic-design+task@raceteam.localhost", "raceteam+task@raceteam.localhost"] }
        let(:expected_reply_to) { '"UCSD Electric Racing: Electronics Tasks" <electronics+task@raceteam.localhost>, "UCSD Electric Racing: Fundraising Tasks" <fundraising+task@raceteam.localhost>, "UCSD Electric Racing: Graphic Design Tasks" <graphic-design+task@raceteam.localhost>, UCSD Electric Racing Tasks <raceteam+task@raceteam.localhost>' }
        let(:expect_reply) { false }

        it 'does not include follow and mute counts' do
          expect(html).to_not include 'muted'
        end
      end

      context 'with muters or followers' do
        it 'displays the count' do
          expect(html).to include '0 followers, 1 muted'
          expect(html).to include conversation_detail_url(organization, 'my', conversation)
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
        allow(message).to receive_messages body: body_double
        allow(message).to receive_messages body_plain: body_double
      }
      it "returns the first bunch of characters of the summary" do
        expect(mail.html_part.body.to_s).to include "#{message.body.to_s[0,200]}"
      end

      context "with a short message" do
        let(:body){ "Everybody, please." }
        it "pads the remaining characters with spaces and then periods when the message is short" do
          expect(mail.html_part.body.to_s).to include "Everybody, please.#{' '*82}#{'_'*82}"
        end
      end
    end

    describe "mail buttons" do
      context "with mail buttons enabled" do
        it "has the buttons in the mail" do
          expect(mail.html_part.body.to_s).to include 'class="threadable-button"'
          expect(mail.html_part.body.to_s).not_to include 'class="threadable-conversation"'
        end

        context "as a group member" do
          it "has a mute button" do
            expect(mail.html_part.body.to_s).to include 'Mute'
            expect(mail.html_part.body.to_s).not_to include 'Unfollow'
            expect(mail.text_part.body.to_s).to include 'Mute'
            expect(mail.text_part.body.to_s).not_to include 'Unfollow'
          end
        end

        context "as a follower" do
          let(:conversation){ organization.conversations.find_by_slug! 'get-a-new-soldering-iron' }
          let(:expected_to) { ["electronics+task@raceteam.localhost"] }
          let(:expected_reply_to) { '"UCSD Electric Racing: Electronics Tasks" <electronics+task@raceteam.localhost>'}

          it "has an unfollow button" do
            expect(mail.html_part.body.to_s).to include 'Unfollow'
            expect(mail.html_part.body.to_s).not_to include 'Mute'
            expect(mail.text_part.body.to_s).to include 'Unfollow'
            expect(mail.text_part.body.to_s).not_to include 'Mute'
          end
        end
      end

      context "with mail buttons disabled" do
        let(:conversation){ organization.conversations.find_by_slug! 'get-a-new-soldering-iron' }

        before do
          recipient.update(show_mail_buttons: false)
        end

        it "doesn't have buttons in the mail" do
          expect(mail.html_part.body.to_s).not_to include 'class="threadable-button"'
          expect(mail.html_part.body.to_s).to include 'web view'
        end
      end
    end

    context 'for first-message recipients' do
      context 'when the recipient has a first-message subscription' do
        let(:group) { conversation.groups.all.first}
        let(:member) { group.members.all.find{|g| g.slug == recipient.slug } }

        before do
          member.gets_first_message!
        end

        it 'has a follow button and a flash' do
          expect(mail.html_part.body.to_s).to include 'Follow'
          expect(mail.html_part.body.to_s).not_to include 'Unfollow'
          expect(mail.html_part.body.to_s).not_to include 'Mute'
          expect(mail.html_part.body.to_s).to include "You'll only receive the first message of this conversation"
          expect(mail.text_part.body.to_s).to include "You'll only receive the first message of this conversation"
        end
      end

      context 'when the recipient has an each-message and a first-message subscription' do
        it 'does not have a follow button or a flash' do
          expect(mail.html_part.body.to_s).not_to include 'Follow'
          expect(mail.html_part.body.to_s).not_to include "You'll only receive the first message of this conversation"
          expect(mail.text_part.body.to_s).not_to include "You'll only receive the first message of this conversation"
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

      context 'with an inline image' do
        let(:attachment_to_inline) { message.attachments.all.first.attachment_record }
        let(:inline_filename) { attachment_to_inline.filename }
        let(:inline_content_id) { attachment_to_inline.content_id }

        before do
          attachment_to_inline.update_attribute(:inline, true)
        end

        it 'inlines the image' do
          expect(mail.attachments.length).to eq 3
          attachment = mail.attachments.find { |attachment| attachment.filename == inline_filename }

          expect(attachment.mime_type).to eq 'image/gif'
          expect(attachment.content_id).to eq inline_content_id
          expect(attachment.header['X-Attachment-Id'].value).to eq inline_content_id.gsub(/<|>/, '')
          expect(attachment.content_disposition).to include 'inline'
          expect(attachment.content_disposition).to include inline_filename
        end
      end

      context 'with different mime types' do
        before do
          message.attachments.all.
            find{ |a| a.filename == attachment_filename}.
            attachment_record.
            update_attributes(mimetype: attachment_mimetype)
        end

        context 'when one of the attachments is of type application/octet-stream' do
          let(:attachment_filename) { 'some.jpg' }
          let(:attachment_mimetype) { 'application/octet-stream' }

          it 'persists the content-type' do
            attachment = mail.attachments.find { |attachment| attachment.filename == 'some.jpg' }
            expect(attachment.mime_type).to eq 'application/octet-stream'
          end
        end

        context 'when one of the attachments is of type message/rfc822' do
          let(:attachment_filename) { 'some.txt' }
          let(:attachment_mimetype) { 'message/rfc822' }

          it 'persists the content-type' do
            attachment = mail.attachments.find { |attachment| attachment.filename == 'some.txt.eml' }
            expect(attachment.mime_type).to eq 'message/rfc822'
          end
        end
      end
    end

  end
end
