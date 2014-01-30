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

  describe '#unmute!' do
    context 'when signed in' do
      before{ covered.current_user_id = conversation.organization.members.who_get_email.first.id }
      it 'removes the current user from the muters' do
        conversation.mute!
        expect(conversation.recipients.all).to_not include covered.current_user
        expect(conversation.unmute!).to eq conversation
        expect(conversation.recipients.all).to include covered.current_user
      end
      it 'still works when the conversation was not muted' do
        expect(conversation.unmute!).to eq conversation
        expect(conversation.recipients.all).to include covered.current_user
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

  describe 'email addresses' do
    let(:no_group_conversation       ) { 'welcome-to-our-covered-organization' }
    let(:single_group_conversation   ) { 'parts-for-the-motor-controller' }
    let(:multiple_group_conversation ) { 'drive-trains-are-expensive' }
    let(:no_group_task               ) { 'layup-body-carbon' }
    let(:single_group_task           ) { 'get-a-new-soldering-iron' }
    let(:multiple_group_task         ) { 'get-some-4-gauge-wire' }

    describe '#formatted_email_addresses' do
      context 'when the conversation is not a task' do
        context 'and there are no groups' do
          let(:conversation) { covered.conversations.find_by_slug!(no_group_conversation) }
          it 'returns the organization email address' do
            expect(conversation.formatted_email_addresses).to eq ['UCSD Electric Racing <raceteam@127.0.0.1>']
          end
        end

        context 'and there is one group' do
          let(:conversation) { covered.conversations.find_by_slug!(single_group_conversation) }
          it 'returns the group email address' do
            expect(conversation.formatted_email_addresses).to eq ['"UCSD Electric Racing: Electronics" <raceteam+electronics@127.0.0.1>']
          end
        end

        context 'and there are many groups' do
          let(:conversation) { covered.conversations.find_by_slug!(multiple_group_conversation) }
          it 'returns a list of all group email addresses' do
            expect(conversation.formatted_email_addresses).to match_array ['"UCSD Electric Racing: Electronics" <raceteam+electronics@127.0.0.1>', '"UCSD Electric Racing: Fundraising" <raceteam+fundraising@127.0.0.1>']
          end
        end
      end

      context 'when the conversation is a task' do
        context 'and there are no groups' do
          let(:conversation) { covered.conversations.find_by_slug!(no_group_task) }
          it 'returns the organization task email address' do
            expect(conversation.formatted_email_addresses).to eq ['UCSD Electric Racing Tasks <raceteam+task@127.0.0.1>']
          end
        end

        context 'and there is one group' do
          let(:conversation) { covered.conversations.find_by_slug!(single_group_task) }
          it 'returns the group task email address' do
            expect(conversation.formatted_email_addresses).to eq ['"UCSD Electric Racing: Electronics Tasks" <raceteam+electronics+task@127.0.0.1>']
          end
        end

        context 'and there are many groups' do
          let(:conversation) { covered.conversations.find_by_slug!(multiple_group_task) }
          it 'returns a list of all group task email addresses' do
            expect(conversation.formatted_email_addresses).to match_array ['"UCSD Electric Racing: Electronics Tasks" <raceteam+electronics+task@127.0.0.1>', '"UCSD Electric Racing: Fundraising Tasks" <raceteam+fundraising+task@127.0.0.1>']
          end
        end
      end
    end

    describe '#email_addresses' do
      it 'returns just the email address component of the formatted address' do
        expect(conversation.email_addresses).to eq ['raceteam@127.0.0.1']
      end
    end

    describe '#canonical_email_address' do
      it 'returns just the email address component of the canonical formatted address' do
        expect(conversation.canonical_email_address).to eq 'raceteam@127.0.0.1'
      end
    end

    describe '#canonical_formatted_email_address' do
      context 'and there are no groups' do
        let(:conversation) { covered.conversations.find_by_slug!(no_group_conversation) }
        it 'returns the organization formatted email address' do
          expect(conversation.canonical_formatted_email_address).to eq 'UCSD Electric Racing <raceteam@127.0.0.1>'
        end

        context 'and it is a task' do
          let(:conversation) { covered.conversations.find_by_slug!(no_group_task) }
          it 'returns the organization formatted task email address' do
            expect(conversation.canonical_formatted_email_address).to eq 'UCSD Electric Racing Tasks <raceteam+task@127.0.0.1>'
          end
        end
      end

      context 'and there is one group' do
        let(:conversation) { covered.conversations.find_by_slug!(single_group_conversation) }
        it 'returns the group formatted email address' do
          expect(conversation.canonical_formatted_email_address).to eq '"UCSD Electric Racing: Electronics" <raceteam+electronics@127.0.0.1>'
        end
      end

      context 'and there are many groups' do
        let(:conversation) { covered.conversations.find_by_slug!(multiple_group_conversation) }
        it 'returns the organization formatted email address' do
          expect(conversation.canonical_formatted_email_address).to eq 'UCSD Electric Racing <raceteam@127.0.0.1>'
        end
      end
    end
  end
end
