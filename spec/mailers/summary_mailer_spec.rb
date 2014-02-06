# encoding: utf-8
require "spec_helper"

describe SummaryMailer do
  describe "message_summary" do
    signed_in_as 'bethany@ucsd.example.com'

    let(:organization){ current_user.organizations.find_by_slug! 'raceteam' }
    let(:today) { Date.today }
    let(:conversations){ organization.conversations.all_with_updated_date today }
    let(:recipient){ organization.members.all.last }

    let(:mail){ SummaryMailer.new(threadable).generate(:message_summary, organization, recipient, conversations, today) }
    let(:email){ RSpec::Support::SentEmail::Email.new(mail) }

    let(:expected_to           ){ recipient.email_address }
    let(:expected_cc           ){ '' }
    let(:expected_from         ){ organization.formatted_email_address }
    let(:expected_envelope_to  ){ recipient.email_address }
    let(:expected_envelope_from){ organization.email_address }
    let(:expected_html_part    ){ message.body_html.gsub(/\n/,'') }

    let(:mail_as_string){ mail.to_s }
    let(:text_part){ mail.text_part.body.to_s }
    let(:html_part){ mail.html_part.body.to_s }

    def validate_mail!
      mail.subject.should include "[RaceTeam]"
      mail.subject.should include "Summary for"
      mail.subject.should include today.strftime('%a, %b %-d')
      mail.subject.should include '16 new messages in 4 conversations'
      mail.subject.scan('RaceTeam').size.should == 1

      mail.to.should                    == [expected_to]
      mail.header['From'].to_s.should   == expected_from
      mail.smtp_envelope_to.should      == [expected_envelope_to]
      mail.smtp_envelope_from.should    == expected_envelope_from

      organization_unsubscribe_token = extract_organization_unsubscribe_token(text_part)
      expect( OrganizationUnsubscribeToken.decrypt(organization_unsubscribe_token) ).to eq [organization.id, recipient.id]

      expect(email.link('feedback')).to be_present
      expect(email.link('feedback')[:href]).to eq "mailto:support@127.0.0.1"

      expect(text_part).to include "mailto:#{organization.email_address}"
      expect(text_part).to include "mailto:#{organization.task_email_address}"

      expect(mail.header[:'List-ID'].to_s ).to eq organization.list_id
      expect(mail.header[:'Cc'].to_s      ).to eq expected_cc
    end

    it "returns a mail message as expected" do
      validate_mail!
    end


    context "when there are actually no new messages" do
      it "does not send an email"
    end


    # context "message summary" do
    #   pending 'until we have these'
    #   let(:body){
    #     %(Everybody, yeah Rock your body, yeah Everybody, yeah Rock your body right Backstreet's )+
    #     %(back, alright Hey, yeah Oh my God, we're back again Brothers, sisters, everybody sing )+
    #     %(Gonna bring the flavor, show you how Gotta question for you better answer now, yeah)
    #   }
    #   let(:body_double){ double(:body, html?: false, html_safe?: false, to_s: body, length: body.length) }
    #   before{
    #     message.stub body: body_double
    #     message.stub body_plain: body_double
    #   }
    #   it "returns the first bunch of characters of the summary" do
    #     mail.html_part.body.to_s.should include "#{message.body.to_s[0,200]}"
    #   end

    #   context "with a short message" do
    #     let(:body){ "Everybody, please." }
    #     it "pads the remaining characters with spaces and then periods when the message is short" do
    #       mail.html_part.body.to_s.should include "Everybody, please.#{' '*82}#{'_'*82}"
    #     end
    #   end
    # end


  end
end
