# encoding: UTF-8

require 'spec_helper'

describe 'sending emails' do

  def expect_job_to_be_enqueued! *args
    expect(sent_emails).to be_empty
    expect(SendEmailWorker.jobs.length).to eq 1
    job = SendEmailWorker.jobs.first
    expect(job["args"]).to eq [threadable.env, *args]
  end

  def run_jobs!
    SendEmailWorker.drain
  end

  when_signed_in_as 'alice@ucsd.example.com' do

    let(:organization){ current_user.organizations.find_by_slug! 'raceteam' }
    let(:conversation){ organization.conversations.find_by_slug! 'layup-body-carbon' }
    let(:message     ){ conversation.messages.latest }
    let(:recipient   ){ organization.members.find_by_user_id! find_user_by_email_address('yan@ucsd.example.com').id }

    describe 'conversation_message' do

      def expect_email!
        email = sent_emails.to(recipient.email_address).with_subject("Re: [✔\uFE0E][RaceTeam] layup body carbon").first
        expect(email).to be_present
        expect( email.header['From'].to_s        ).to eq 'Tom Canver <tom@ucsd.example.com>'
        expect( email.header['Reply-To'].to_s    ).to eq 'UCSD Electric Racing Tasks <raceteam+task@127.0.0.1>'
        expect( email.header['To'].to_s          ).to eq 'UCSD Electric Racing Tasks <raceteam+task@127.0.0.1>'
        expect( email.header['Date'].to_s        ).to eq message.date_header.sub('-','+')
        expect( email.header['Message-ID'].to_s  ).to eq message.message_id_header
        expect( email.header['In-Reply-To'].to_s ).to eq message.parent_message.message_id_header
        expect( email.header['References'].to_s  ).to eq message.references_header
        expect( email.header['Subject'].to_s     ).to eq "Re: [✔\uFE0E][RaceTeam] layup body carbon"

        expect( email.header['List-ID'].to_s      ).to eq 'UCSD Electric Racing <raceteam.127.0.0.1>'
        expect( email.header['List-Archive'].to_s ).to eq "<#{conversations_url(organization,'my')}>"

        expect( email.header["List-Unsubscribe"].to_s ).to match %r{/raceteam/unsubscribe/}
        expect( email.header["List-Post"].to_s        ).to eq "<mailto:raceteam@127.0.0.1>, <#{compose_conversation_url(organization, 'my')}>"
      end

      context "sync" do
        it "should send email" do
          threadable.emails.send_email(:conversation_message, organization, message, recipient)
          expect_email!
        end
      end
      context "async" do
        it "should schedule a job that sends the email" do
          threadable.emails.send_email_async(:conversation_message, organization.id, message.id, recipient.id)
          expect(sent_emails).to be_empty
          expect_job_to_be_enqueued! "conversation_message", organization.id, message.id, recipient.id
          run_jobs!
          expect_email!
        end
      end

      context "when there are multiple people in the TO and CC headers" do
        let(:conversation){ organization.conversations.find_by_slug! 'who-wants-to-pick-up-lunch' }
        it "should filter out organization members from the TO and CC headers" do
          threadable.emails.send_email(:conversation_message, organization, message, recipient)

          email = sent_emails.to(recipient.email_address).with_subject("[RaceTeam] Who wants to pick up lunch?").first

          expect( email.header['To'].to_s ).to_not be_blank
          expect( email.header['To'].to_s ).to     include 'UCSD Electric Racing <raceteam@127.0.0.1>'
          expect( email.header['To'].to_s ).to     include 'somebody@else.io'
          expect( email.header['To'].to_s ).to_not include 'alice@ucsd.example.com'
          expect( email.header['To'].to_s ).to_not include 'bethany@ucsd.example.com'

          expect( email.header['Cc'].to_s ).to     include 'another@random-person.com'
          expect( email.header['Cc'].to_s ).to_not include 'bob@ucsd.example.com'
        end
      end

      context 'when the organization is in the CC header and there are multiple people in the TO and CC headers' do
        let(:conversation){ organization.conversations.find_by_slug! 'who-wants-to-pick-up-dinner' }

        it "should include the organization in the CC header" do
          threadable.emails.send_email(:conversation_message, organization, message, recipient)

          email = sent_emails.to(recipient.email_address).with_subject("[RaceTeam] Who wants to pick up dinner?").first

          expect( email.header['To'].to_s ).to_not be_blank
          expect( email.header['Cc'].to_s ).to include 'UCSD Electric Racing <raceteam@127.0.0.1>'
        end
      end
      context 'when the organization is in the BCC header and there are multiple people in the TO and CC headers' do
        let(:conversation){ organization.conversations.find_by_slug! 'who-wants-to-pick-up-breakfast' }

        it "should not include the organization email address in the TO or CC headers" do
          threadable.emails.send_email(:conversation_message, organization, message, recipient)

          email = sent_emails.to(recipient.email_address).with_subject("[RaceTeam] Who wants to pick up breakfast?").first

          expect( email.header['To'].to_s ).to_not be_blank
          expect( email.header['Cc'].to_s ).to_not include 'UCSD Electric Racing <raceteam@127.0.0.1>'
          expect( email.header['To'].to_s ).to_not include 'UCSD Electric Racing <raceteam@127.0.0.1>'
        end
      end
    end

    describe 'join_notice' do
      let(:personal_message){ "Hey dude, can you help us out please?"}

      def expect_email!
        email = sent_emails.to(recipient.email_address).with_subject("You've been added to UCSD Electric Racing").first
        expect(email).to be_present
        expect(email.body.encoded).to include personal_message
      end

      context "sync" do
        it "should send email" do
          threadable.emails.send_email(:join_notice, organization, recipient, personal_message)
          expect_email!
        end
      end
      context "async" do
        it "should schedule a job that sends the email" do
          threadable.emails.send_email_async(:join_notice, organization.id, recipient.id, personal_message)
          expect(sent_emails).to be_empty
          expect_job_to_be_enqueued! "join_notice", organization.id, recipient.id, personal_message
          run_jobs!
          expect_email!
        end
      end
    end

    describe 'unsubscribe_notice' do

      def expect_email!
        email = sent_emails.to(recipient.email_address).with_subject("You've been unsubscribed from UCSD Electric Racing").first
        expect(email).to be_present
      end

      context "sync" do
        it "should send email" do
          threadable.emails.send_email(:unsubscribe_notice, organization, recipient)
          expect_email!
        end
      end
      context "async" do
        it "should schedule a job that sends the email" do
          threadable.emails.send_email_async(:unsubscribe_notice, organization.id, recipient.id)
          expect(sent_emails).to be_empty
          expect_job_to_be_enqueued! "unsubscribe_notice", organization.id, recipient.id
          run_jobs!
          expect_email!
        end
      end
    end

    describe 'sign_up_confirmation' do

      let(:email_address){ 'max.born@gmail.com' }

      def expect_email!
        email = sent_emails.to(email_address).with_subject("Welcome to Threadable!").first
        expect(email).to be_present
      end

      context "sync" do
        it "should send email" do
          threadable.emails.send_email(:sign_up_confirmation, email_address)
          expect_email!
        end
      end
      context "async" do
        it "should schedule a job that sends the email" do
          threadable.emails.send_email_async(:sign_up_confirmation, email_address)
          expect(sent_emails).to be_empty
          expect_job_to_be_enqueued! "sign_up_confirmation", email_address
          run_jobs!
          expect_email!
        end
      end
    end

    describe 'reset_password' do

      def expect_email!
        email = sent_emails.to(recipient.email_address).with_subject("Reset your password!").first
        expect(email).to be_present
      end

      context "sync" do
        it "should send email" do
          threadable.emails.send_email(:reset_password, recipient)
          expect_email!
        end
      end
      context "async" do
        it "should schedule a job that sends the email" do
          threadable.emails.send_email_async(:reset_password, recipient.id)
          expect(sent_emails).to be_empty
          expect_job_to_be_enqueued! "reset_password", recipient.id
          run_jobs!
          expect_email!
        end
      end
    end

  end

end
