require 'spec_helper'

describe Covered::Emails do

  subject{ covered.emails }

  describe 'send_email' do
    it 'calls generate and deliver' do
      email_double = double(:email)
      expect(subject).to receive(:generate).with(:foo, 1,2,3).and_return(email_double)
      expect(email_double).to receive(:deliver!)
      subject.send_email(:foo, 1,2,3)
    end
  end

  describe 'send_email_async' do
    it 'schedules a SendEmailWorker job' do
      expect(SendEmailWorker).to receive(:perform_async).with(covered.env, :conversation_message, 45, :a)
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
        expect(ConversationMailer).to receive(:new).with(covered).and_return(mailer)
        expect(mailer).to receive(:generate).with(:conversation_message, 1,2,3).and_return('A Mail::Message')
        expect(subject.generate(:conversation_message, 1,2,3)).to eq 'A Mail::Message'
      end
    end
    context 'when given :join_notice as the type' do
      it 'calls ProjectMembershipMailer#join_notice' do
        expect(ProjectMembershipMailer).to receive(:new).with(covered).and_return(mailer)
        expect(mailer).to receive(:generate).with(:join_notice, 1,2,3).and_return('A Mail::Message')
        expect(subject.generate(:join_notice, 1,2,3)).to eq 'A Mail::Message'
      end
    end
    context 'when given :unsubscribe_notice as the type' do
      it 'calls ProjectMembershipMailer#unsubscribe_notice' do
        expect(ProjectMembershipMailer).to receive(:new).with(covered).and_return(mailer)
        expect(mailer).to receive(:generate).with(:unsubscribe_notice, 1,2,3).and_return('A Mail::Message')
        expect(subject.generate(:unsubscribe_notice, 1,2,3)).to eq 'A Mail::Message'
      end
    end
    context 'when given :sign_up_confirmation as the type' do
      it 'calls UserMailer#sign_up_confirmation' do
        expect(UserMailer).to receive(:new).with(covered).and_return(mailer)
        expect(mailer).to receive(:generate).with(:sign_up_confirmation, 1,2,3).and_return('A Mail::Message')
        expect(subject.generate(:sign_up_confirmation, 1,2,3)).to eq 'A Mail::Message'
      end
    end
    context 'when given :reset_password as the type' do
      it 'calls UserMailer#reset_password' do
        expect(UserMailer).to receive(:new).with(covered).and_return(mailer)
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
