# Encoding: UTF-8
require "spec_helper"

describe OrganizationMembershipMailer do

  signed_in_as 'bethany@ucsd.covered.io'

  let(:project){ current_user.projects.find_by_slug! 'raceteam' }
  let(:conversation){ project.conversations.find_by_slug! 'layup-body-carbon' }
  let(:message){ conversation.messages.latest }
  let(:text_part){ mail.body.encoded }

  describe "join_notice" do
    let(:personal_message){ "yo dude, I added you to the project. Thanks for the help!" }
    let(:mail){ OrganizationMembershipMailer.new(covered).generate(:join_notice, project, recipient, personal_message) }

    before do
      expect(mail.subject).to eq "You've been added to #{project.name}"
      expect(mail.to     ).to eq [recipient.email_address.to_s]
      expect(mail.from   ).to eq ['bethany@ucsd.covered.io']
      expect(text_part   ).to include personal_message
      expect(text_part   ).to include project_url(project)

      project_unsubscribe_token = extract_project_unsubscribe_token(text_part)
      expect( OrganizationUnsubscribeToken.decrypt(project_unsubscribe_token) ).to eq [project.id, recipient.id]
    end

    context "when the recipient is a web enabled user" do
      let(:recipient){ project.members.all.find(&:web_enabled?) }

      it "should not have a user setup link" do
        user_setup_token = extract_user_setup_token(text_part)
        expect( user_setup_token ).to be_nil
      end
    end

    context "when the recipient is not a web enabled user" do
      let(:recipient){ project.members.all.reject(&:web_enabled?).first }

      it "should have a user setup link" do
        user_setup_token = extract_user_setup_token(text_part)
        expect(UserSetupToken.decrypt(user_setup_token)).to eq [recipient.id, project_path(project)]
      end
    end

  end

  describe "unsubscribe_notice" do
    let(:member){ project.members.find_by_user_id!(covered.current_user.id) }
    let(:mail){ OrganizationMembershipMailer.new(covered).generate(:unsubscribe_notice, project, member) }
    it "should return the expected message" do
      expect(mail.subject ).to eq "You've been unsubscribed from #{project.name}"
      expect(mail.to      ).to eq ['bethany@ucsd.covered.io']
      expect(mail.from    ).to eq [project.email_address.to_s]
      expect(text_part    ).to include %(You've been unsubscribed from the "#{project.name}" project on Covered.)

      project_resubscribe_token = extract_project_resubscribe_token(text_part)
      expect( OrganizationResubscribeToken.decrypt(project_resubscribe_token) ).to eq [project.id, current_user.id]
    end
  end


end
