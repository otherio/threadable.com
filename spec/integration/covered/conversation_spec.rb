require 'spec_helper'

describe Covered::Conversation do

  let(:conversation){ covered.conversations.find_by_slug!('welcome-to-our-covered-organization') }
  subject{ conversation }


  describe '#mute!' do
    context 'when signed in' do
      before{ covered.current_user_id = conversation.organization.members.who_get_email.first.id }
      it 'adds the current user to the conversation muters' do
        expect(conversation.recipients.all).to include covered.current_user
        expect(conversation.mute!).to eq conversation
        expect(conversation.recipients.all).to_not include covered.current_user
      end
    end
    context 'when not signed in' do
      before{ covered.current_user_id = nil }
      it 'raises an ArgumentError' do
        expect{ conversation.mute! }.to raise_error ArgumentError
      end
    end
  end

  describe '#muted?' do
    context 'when signed in' do
      before{ covered.current_user_id = conversation.organization.members.who_get_email.first.id }
      it 'checks the muted state of the conversation' do
        expect(conversation.muted?).to be_false
        conversation.mute!
        expect(conversation.muted?).to be_true
      end
    end

    context 'when not signed in' do
      before{ covered.current_user_id = nil }
      it 'raises an ArgumentError' do
        expect{ conversation.muted? }.to raise_error ArgumentError
      end
    end

  end

end
