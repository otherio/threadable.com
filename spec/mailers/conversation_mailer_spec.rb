# encoding: utf-8
require "spec_helper"

describe ConversationMailer do
  describe "conversation_message" do

    before do
      Rails.application.routes.default_url_options[:host] = 'covered.io'
    end

    let(:project){ Covered::Project.where(name: 'UCSD Electric Racing').first }
    let(:conversation){ project.conversations.find_by_subject('layup body carbon') }
    let(:parent_message){ conversation.messages.last }
    let(:creator){ project.members.with_email("jonathan@ucsd.covered.io").first! }
    let(:from){ creator.try(:formatted_email_address) }
    let(:body_plain) { 'This is the best project everz.' }

    let(:message){
      conversation.messages.create!(
        from:           from,
        creator:        creator,
        subject:        conversation.subject,
        body_plain:     body_plain,
        parent_message: parent_message,
      )
    }

    let(:project_membership){ recipient.project_memberships.where(project: project).first! }

    let(:recipient){ project.members.with_email("bethany@ucsd.covered.io").first! }

    subject(:mail) {
      covered.generate_email(type: :conversation_message, options: {
        message_id: message.id, recipient_id: recipient.id
      })
    }

    let(:mail_as_text){ mail.to_s }
    let(:html_body) { mail.html_part.body.to_s }

    let(:expected_to           ){ project.email_address }
    let(:expected_from         ){ creator.email_address }
    let(:expected_envelope_to  ){ recipient.email_address }
    let(:expected_envelope_from){ project.email_address }

    def validate_mail!
      mail.subject.should include "[RaceTeam] #{conversation.subject}"
      mail.subject.scan('RaceTeam').size.should == 1

      mail.to.should                 == [expected_to]
      mail.from.should               == [expected_from]
      mail.smtp_envelope_to.should   == [expected_envelope_to]
      mail.smtp_envelope_from.should == expected_envelope_from

      mail_as_text.should =~ /In-Reply-To:/
      mail_as_text.should =~ /References:/
      mail_as_text.should =~ /Message-ID:/
      mail_as_text.should include 'This is the best project everz.'
      mail_as_text.should include "View on Covered:\r\n#{project_conversation_url(project, conversation)}"
      mail_as_text =~ /\/#{Regexp.escape(project.slug)}\/unsubscribe\/([^>\s]+)/ #the list-unsubscribe in the header is wrapped in <>

      unsubscribe_token = $1
      unsubscribe_token.should_not be_blank
      unsubscribe_token = URI.decode(unsubscribe_token)
      ProjectUnsubscribeToken.decrypt(unsubscribe_token).should == project_membership.id

      mail.header[:'Reply-To'].to_s.should == project.formatted_email_address
      mail.header[:'List-ID'].to_s.should == project.formatted_list_id
      mail.in_reply_to.should == message.parent_message.message_id_header[1..-2]
      mail.message_id.should == message.message_id_header[1..-2]
      mail.references.should == [
        parent_message.references_header.scan(/<(.+)>/).first.first,
        parent_message.message_id_header.scan(/<(.+)>/).first.first
      ]
    end

    it "returns a mail message as expected" do
      validate_mail!
    end

    context "when the subject is a reply" do
      before do
        message.subject = "RE: Re: [RaceTeam] #{conversation.subject}"
      end
      it "should parse and construct the correct subject" do
        validate_mail!
      end
    end

    context "when we send a message to the message author" do
      let(:recipient){ message.user }
      let(:expected_from){ project.email }
      it "should set the from address as the project instead of the sender" do
        validate_mail!
      end
    end

    context "when given a message without a user" do
      let(:creator){ nil }
      let(:from){ 'larry@bird.com' }
      let(:expected_from){ from }
      it "should set the from address to the incomming messages's from address" do
        validate_mail!
      end
    end

    context "message summary" do
      let(:body_plain) { "Everybody, yeah Rock your body, yeah Everybody, yeah Rock your body right Backstreet's back, alright Hey, yeah Oh my God, we're back again Brothers, sisters, everybody sing Gonna bring the flavor, show you how Gotta question for you better answer now, yeah"}

      it "returns the first bunch of characters of the summary, with an umbrella" do
        mail
        html_body.should =~ /⌁ Everybody, yeah Rock your body, yeah Everybody, yeah Rock your body right Backstreet's back, alright Hey, yeah Oh my God, we're back again Brothers, sisters,/
      end

      context "with a short message" do
        let(:body_plain) { "Everybody, please." }
        it "pads the remaining characters with underscores when the message is short" do
          mail
          html_body.should =~ /⌁ Everybody, please._{150}/
        end
      end
    end
  end
end
