# Encoding: UTF-8
require "spec_helper"

describe MembershipMailer do

  signed_in_as 'bethany@ucsd.example.com'

  let(:organization){ current_user.organizations.find_by_slug! 'raceteam' }
  let(:conversation){ organization.conversations.find_by_slug! 'layup-body-carbon' }
  let(:message){ conversation.messages.latest }
  let(:text_part){ mail.body.encoded }

  describe "join_notice" do
    let(:personal_message){ "yo dude, I added you to the organization. Thanks for the help!" }
    let(:mail){ MembershipMailer.new(threadable).generate(:join_notice, organization, recipient, personal_message) }

    before do
      expect(mail.subject).to eq "You've been added to #{organization.name}"
      expect(mail.to     ).to eq [recipient.email_address.to_s]
      expect(mail.from   ).to eq ['bethany@ucsd.example.com']
      expect(text_part   ).to include personal_message
      expect(text_part   ).to include organization_url(organization)

      organization_unsubscribe_token = extract_organization_unsubscribe_token(text_part)
      expect( OrganizationUnsubscribeToken.decrypt(organization_unsubscribe_token) ).to eq [organization.id, recipient.id]
    end

    context "when the recipient is a web enabled user" do
      let(:recipient){ organization.members.all.find(&:web_enabled?) }

      it "should not have a user setup link" do
        user_setup_token = extract_user_setup_token(text_part)
        expect( user_setup_token ).to be_nil
      end
    end

    context "when the recipient is not a web enabled user" do
      let(:recipient){ organization.members.all.reject(&:web_enabled?).first }

      it "should have a user setup link" do
        user_setup_token = extract_user_setup_token(text_part)
        expect(UserSetupToken.decrypt(user_setup_token)).to eq [recipient.id, organization_path(organization)]
      end
    end

  end

  describe "unsubscribe_notice" do
    let(:member){ organization.members.find_by_user_id!(threadable.current_user.id) }
    let(:mail){ MembershipMailer.new(threadable).generate(:unsubscribe_notice, organization, member) }
    it "should return the expected message" do
      expect(mail.subject ).to eq "You've been unsubscribed from #{organization.name}"
      expect(mail.to      ).to eq ['bethany@ucsd.example.com']
      expect(mail.from    ).to eq [organization.email_address.to_s]
      expect(text_part    ).to include %(You've been unsubscribed from the "#{organization.name}" organization on Threadable.)

      organization_resubscribe_token = extract_organization_resubscribe_token(text_part)
      expect( OrganizationResubscribeToken.decrypt(organization_resubscribe_token) ).to eq [organization.id, current_user.id]
    end
  end


end
