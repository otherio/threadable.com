require 'spec_helper'

describe Threadable::Emails do

  subject{ threadable.emails }

  describe 'send_email' do
    let(:envelope_to) { 'other@guy.com' }
    let(:email_double) { double(:email, smtp_envelope_from: 'some@guy.com', smtp_envelope_to: envelope_to) }

    before do
      expect(Threadable::Emails::Validate).to receive(:call).with(email_double).and_return(true)
    end

    it 'calls generate and deliver' do
      expect(subject).to receive(:generate).with(:foo, 1,2,3).and_return(email_double)
      expect(email_double).to receive(:deliver)
      subject.send_email(:foo, 1,2,3)
    end

    context "if the recipient is at example.com" do
      let(:envelope_to) { 'other@foo.example.com' }

      it "skips the message" do
        expect(subject).to receive(:generate).with(:foo, 1,2,3).and_return(email_double)
        expect(email_double).to_not receive(:deliver)
        subject.send_email(:foo, 1,2,3)
      end
    end
  end

  describe 'send_email_async' do
    it 'schedules a SendEmailWorker job' do
      expect(SendEmailWorker).to receive(:perform_async).with(threadable.env, :conversation_message, 45, :a)
      subject.send_email_async(:conversation_message, 45, :a)
    end
    context 'when given an invalid type' do
      it 'raises and ArgumentError' do
        expect{ subject.generate(:bad_type) }.to raise_error ArgumentError, 'unknown email type: bad_type'
      end
    end
  end

  describe 'generate' do
    let(:mailer){ double :mailer }
    context 'when given :conversation_message as the type' do
      it 'calls ConversationMailer#conversation_message' do
        expect(ConversationMailer).to receive(:new).with(threadable).and_return(mailer)
        expect(mailer).to receive(:generate).with(:conversation_message, 1,2,3).and_return('A Mail::Message')
        expect(subject.generate(:conversation_message, 1,2,3)).to eq 'A Mail::Message'
      end
    end
    context 'when given :join_notice as the type' do
      it 'calls OrganizationMembershipMailer#join_notice' do
        expect(OrganizationMembershipMailer).to receive(:new).with(threadable).and_return(mailer)
        expect(mailer).to receive(:generate).with(:join_notice, 1,2,3).and_return('A Mail::Message')
        expect(subject.generate(:join_notice, 1,2,3)).to eq 'A Mail::Message'
      end
    end
    context 'when given :unsubscribe_notice as the type' do
      it 'calls OrganizationMembershipMailer#unsubscribe_notice' do
        expect(OrganizationMembershipMailer).to receive(:new).with(threadable).and_return(mailer)
        expect(mailer).to receive(:generate).with(:unsubscribe_notice, 1,2,3).and_return('A Mail::Message')
        expect(subject.generate(:unsubscribe_notice, 1,2,3)).to eq 'A Mail::Message'
      end
    end
    context 'when given :sign_up_confirmation as the type' do
      it 'calls UserMailer#sign_up_confirmation' do
        expect(UserMailer).to receive(:new).with(threadable).and_return(mailer)
        expect(mailer).to receive(:generate).with(:sign_up_confirmation, 1,2,3).and_return('A Mail::Message')
        expect(subject.generate(:sign_up_confirmation, 1,2,3)).to eq 'A Mail::Message'
      end
    end
    context 'when given :reset_password as the type' do
      it 'calls UserMailer#reset_password' do
        expect(UserMailer).to receive(:new).with(threadable).and_return(mailer)
        expect(mailer).to receive(:generate).with(:reset_password, 1,2,3).and_return('A Mail::Message')
        expect(subject.generate(:reset_password, 1,2,3)).to eq 'A Mail::Message'
      end
    end
    context 'when given an invalid type' do
      it 'raises and ArgumentError' do
        expect{ subject.generate(:bad_type) }.to raise_error ArgumentError, 'unknown email type: bad_type'
      end
    end
  end


end