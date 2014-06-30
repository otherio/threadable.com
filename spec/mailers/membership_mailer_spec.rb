# Encoding: UTF-8
require "spec_helper"

describe MembershipMailer do

  signed_in_as 'bethany@ucsd.example.com'

  let(:organization){ current_user.organizations.find_by_slug! 'raceteam' }
  let(:conversation){ organization.conversations.find_by_slug! 'layup-body-carbon' }
  let(:group) { organization.groups.find_by_email_address_tag('electronics') }

  let(:message){ conversation.messages.latest }
  let(:text_part){ mail.body.encoded }

  let(:dmarc_verified) { true }

  before do
    VerifyDmarc.stub(:call).and_return(dmarc_verified)
  end

  describe "join_notice" do
    let(:personal_message){ "yo dude, I added you to the organization. Thanks for the help!" }
    let(:mail){ MembershipMailer.new(threadable).generate(:join_notice, organization, recipient, personal_message) }

    before do
      expect(mail.subject).to eq "You've been added to #{organization.name}"
      expect(mail.to     ).to eq [recipient.email_address.to_s]
      expect(text_part   ).to include personal_message
      expect(text_part   ).to include organization_url(organization)

      expect(mail.smtp_envelope_to  ).to eq [recipient.email_address.to_s]
      expect(mail.smtp_envelope_from).to eq organization.email_address

      organization_unsubscribe_token = extract_organization_unsubscribe_token(text_part)
      expect( OrganizationUnsubscribeToken.decrypt(organization_unsubscribe_token) ).to eq [organization.id, recipient.id]
    end

    context "when the recipient is a web enabled user" do
      let(:recipient){ organization.members.all.find(&:web_enabled?) }

      it "should not have a user setup link" do
        user_setup_token = extract_user_setup_token(text_part)
        expect( user_setup_token ).to be_nil
        expect(mail.from).to eq ['bethany@ucsd.example.com']
      end
    end

    context "when the recipient is not a web enabled user" do
      let(:recipient){ organization.members.all.reject(&:web_enabled?).first }

      it "should have a user setup link" do
        user_setup_token = extract_user_setup_token(text_part)
        expect(UserSetupToken.decrypt(user_setup_token)).to eq [recipient.id, organization_path(organization)]
        expect(mail.from).to eq ['bethany@ucsd.example.com']
      end
    end

    context 'when the sender domain has a restrictive dmarc policy' do
      let(:recipient){ organization.members.all.find(&:web_enabled?) }
      let(:dmarc_verified) { false }
      it "has different from and reply-to addresses" do
        expect(mail.header['From'].to_s).to eq 'Bethany Pattern via Threadable <placeholder@localhost>'
        expect(mail.header['Reply-to'].to_s).to eq 'Bethany Pattern <bethany@ucsd.example.com>'
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

      expect(mail.smtp_envelope_to  ).to eq ['bethany@ucsd.example.com']
      expect(mail.smtp_envelope_from).to eq organization.email_address

      organization_resubscribe_token = extract_organization_resubscribe_token(text_part)
      expect( OrganizationResubscribeToken.decrypt(organization_resubscribe_token) ).to eq [organization.id, current_user.id]
    end
  end

  describe 'added_to_group_notice' do
    let(:sender){ organization.members.find_by_user_id!(threadable.current_user.id) }
    let(:member) { organization.members.find_by_email_address('tom@ucsd.example.com') }
    let(:mail){ MembershipMailer.new(threadable).generate(:added_to_group_notice, organization, group, sender, member) }

    it "should return the expected message" do
      expect(mail.subject ).to eq "I added you to #{group.name} on #{organization.name}"
      expect(mail.to      ).to eq ['tom@ucsd.example.com']
      expect(mail.from    ).to eq [sender.email_address.to_s]
      expect(text_part    ).to include 'This message was automatically generated'
      expect(text_part    ).to include %(I added you to the #{group.name} group)
      expect(text_part    ).to include %("#{organization.name}" organization on Threadable.)
      expect(text_part    ).to include conversations_url(organization, group)

      expect(mail.smtp_envelope_to  ).to eq ['tom@ucsd.example.com']
      expect(mail.smtp_envelope_from).to eq organization.email_address
    end

    context 'when the sender domain has a restrictive dmarc policy' do
      let(:dmarc_verified) { false }
      it "has different from and reply-to addresses" do
        expect(mail.header['From'].to_s).to eq 'Bethany Pattern via Threadable <placeholder@localhost>'
        expect(mail.header['Reply-to'].to_s).to eq 'Bethany Pattern <bethany@ucsd.example.com>'

        expect(mail.smtp_envelope_to  ).to eq ['tom@ucsd.example.com']
        expect(mail.smtp_envelope_from).to eq organization.email_address
      end
    end
  end

  describe 'removed_from_group_notice' do
    let(:sender){ organization.members.find_by_user_id!(threadable.current_user.id) }
    let(:member) { organization.members.find_by_email_address('tom@ucsd.example.com') }
    let(:mail){ MembershipMailer.new(threadable).generate(:removed_from_group_notice, organization, group, sender, member) }

    it "should return the expected message" do
      expect(mail.subject ).to eq "I removed you from #{group.name} on #{organization.name}"
      expect(mail.to      ).to eq ['tom@ucsd.example.com']
      expect(mail.from    ).to eq [sender.email_address.to_s]
      expect(text_part    ).to include 'This message was automatically generated'
      expect(text_part    ).to include %(I removed you from the #{group.name} group)
      expect(text_part    ).to include %("#{organization.name}" organization on Threadable.)
      expect(text_part    ).to include group_members_url(organization, group)

      expect(mail.smtp_envelope_to  ).to eq ['tom@ucsd.example.com']
      expect(mail.smtp_envelope_from).to eq organization.email_address
    end

    context 'when the sender domain has a restrictive dmarc policy' do
      let(:dmarc_verified) { false }
      it "has different from and reply-to addresses" do
        expect(mail.header['From'].to_s).to eq 'Bethany Pattern via Threadable <placeholder@localhost>'
        expect(mail.header['Reply-to'].to_s).to eq 'Bethany Pattern <bethany@ucsd.example.com>'

        expect(mail.smtp_envelope_to  ).to eq ['tom@ucsd.example.com']
        expect(mail.smtp_envelope_from).to eq organization.email_address
      end
    end
  end

  describe 'invitation' do
    let(:sender){ organization.members.find_by_user_id!(threadable.current_user.id) }
    let(:member) { organization.members.find_by_email_address('tom@ucsd.example.com') }
    let(:mail){ MembershipMailer.new(threadable).generate(:invitation, organization, member) }

    it "should return the expected message" do
      expect(mail.subject ).to eq "You've been invited to #{organization.name}"
      expect(mail.to      ).to eq ['tom@ucsd.example.com']
      expect(mail.from    ).to eq [sender.email_address.to_s]

      expect(mail.smtp_envelope_to  ).to eq ['tom@ucsd.example.com']
      expect(mail.smtp_envelope_from).to eq organization.email_address
    end

    context 'when the sender domain has a restrictive dmarc policy' do
      let(:dmarc_verified) { false }
      it "has different from and reply-to addresses" do
        expect(mail.header['From'].to_s).to eq 'Bethany Pattern via Threadable <placeholder@localhost>'
        expect(mail.header['Reply-to'].to_s).to eq 'Bethany Pattern <bethany@ucsd.example.com>'

        expect(mail.smtp_envelope_to  ).to eq ['tom@ucsd.example.com']
        expect(mail.smtp_envelope_from).to eq organization.email_address
      end
    end
  end

end
