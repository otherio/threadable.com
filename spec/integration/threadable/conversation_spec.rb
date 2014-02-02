require 'spec_helper'

describe Threadable::Conversation do

  let(:conversation){ threadable.conversations.find_by_slug!('welcome-to-our-threadable-organization') }
  subject{ conversation }


  describe '#mute!' do
    context 'when signed in' do
      before{ threadable.current_user_id = conversation.organization.members.who_get_email.first.id }
      it 'adds the current user to the conversation muters' do
        expect(conversation.recipients.all).to include threadable.current_user
        expect(conversation.mute!).to eq conversation
        expect(conversation.recipients.all).to_not include threadable.current_user
      end
    end
    context 'when not signed in' do
      before{ threadable.current_user_id = nil }
      it 'raises an ArgumentError' do
        expect{ conversation.mute! }.to raise_error ArgumentError
      end
    end
  end

  describe '#unmute!' do
    context 'when signed in' do
      before{ threadable.current_user_id = conversation.organization.members.who_get_email.first.id }
      it 'removes the current user from the muters' do
        conversation.mute!
        expect(conversation.recipients.all).to_not include threadable.current_user
        expect(conversation.unmute!).to eq conversation
        expect(conversation.recipients.all).to include threadable.current_user
      end
      it 'still works when the conversation was not muted' do
        expect(conversation.unmute!).to eq conversation
        expect(conversation.recipients.all).to include threadable.current_user
      end
    end
    context 'when not signed in' do
      before{ threadable.current_user_id = nil }
      it 'raises an ArgumentError' do
        expect{ conversation.mute! }.to raise_error ArgumentError
      end
    end
  end

  describe '#muted?' do
    context 'when signed in' do
      before{ threadable.current_user_id = conversation.organization.members.who_get_email.first.id }
      it 'checks the muted state of the conversation' do
        expect(conversation.muted?).to be_false
        conversation.mute!
        expect(conversation.muted?).to be_true
      end
    end

    context 'when not signed in' do
      before{ threadable.current_user_id = nil }
      it 'raises an ArgumentError' do
        expect{ conversation.muted? }.to raise_error ArgumentError
      end
    end
  end

  describe 'email addresses' do
    let(:no_group_conversation       ) { 'welcome-to-our-threadable-organization' }
    let(:single_group_conversation   ) { 'parts-for-the-motor-controller' }
    let(:multiple_group_conversation ) { 'drive-trains-are-expensive' }
    let(:no_group_task               ) { 'layup-body-carbon' }
    let(:single_group_task           ) { 'get-a-new-soldering-iron' }
    let(:multiple_group_task         ) { 'get-some-4-gauge-wire' }

    describe '#formatted_email_addresses' do
      context 'when the conversation is not a task' do
        context 'and there are no groups' do
          let(:conversation) { threadable.conversations.find_by_slug!(no_group_conversation) }
          it 'returns the organization email address' do
            expect(conversation.formatted_email_addresses).to eq ['UCSD Electric Racing <raceteam@127.0.0.1>']
          end
        end

        context 'and there is one group' do
          let(:conversation) { threadable.conversations.find_by_slug!(single_group_conversation) }
          it 'returns the group email address' do
            expect(conversation.formatted_email_addresses).to eq ['"UCSD Electric Racing: Electronics" <raceteam+electronics@127.0.0.1>']
          end
        end

        context 'and there are many groups' do
          let(:conversation) { threadable.conversations.find_by_slug!(multiple_group_conversation) }
          it 'returns a list of all group email addresses' do
            expect(conversation.formatted_email_addresses).to match_array ['"UCSD Electric Racing: Electronics" <raceteam+electronics@127.0.0.1>', '"UCSD Electric Racing: Fundraising" <raceteam+fundraising@127.0.0.1>']
          end
        end
      end

      context 'when the conversation is a task' do
        context 'and there are no groups' do
          let(:conversation) { threadable.conversations.find_by_slug!(no_group_task) }
          it 'returns the organization task email address' do
            expect(conversation.formatted_email_addresses).to eq ['UCSD Electric Racing Tasks <raceteam+task@127.0.0.1>']
          end
        end

        context 'and there is one group' do
          let(:conversation) { threadable.conversations.find_by_slug!(single_group_task) }
          it 'returns the group task email address' do
            expect(conversation.formatted_email_addresses).to eq ['"UCSD Electric Racing: Electronics Tasks" <raceteam+electronics+task@127.0.0.1>']
          end
        end

        context 'and there are many groups' do
          let(:conversation) { threadable.conversations.find_by_slug!(multiple_group_task) }
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
        let(:conversation) { threadable.conversations.find_by_slug!(no_group_conversation) }
        it 'returns the organization formatted email address' do
          expect(conversation.canonical_formatted_email_address).to eq 'UCSD Electric Racing <raceteam@127.0.0.1>'
        end

        context 'and it is a task' do
          let(:conversation) { threadable.conversations.find_by_slug!(no_group_task) }
          it 'returns the organization formatted task email address' do
            expect(conversation.canonical_formatted_email_address).to eq 'UCSD Electric Racing Tasks <raceteam+task@127.0.0.1>'
          end
        end
      end

      context 'and there is one group' do
        let(:conversation) { threadable.conversations.find_by_slug!(single_group_conversation) }
        it 'returns the group formatted email address' do
          expect(conversation.canonical_formatted_email_address).to eq '"UCSD Electric Racing: Electronics" <raceteam+electronics@127.0.0.1>'
        end
      end

      context 'and there are many groups' do
        let(:conversation) { threadable.conversations.find_by_slug!(multiple_group_conversation) }
        it 'returns the organization formatted email address' do
          expect(conversation.canonical_formatted_email_address).to eq 'UCSD Electric Racing <raceteam@127.0.0.1>'
        end
      end
    end

    describe '#list_id' do
      context 'and there are no groups' do
        let(:conversation) { threadable.conversations.find_by_slug!(no_group_conversation) }
        it 'returns the organization list id' do
          expect(conversation.list_id).to eq 'UCSD Electric Racing <raceteam.127.0.0.1>'
        end

        context 'and it is a task' do
          let(:conversation) { threadable.conversations.find_by_slug!(no_group_task) }
          it 'returns the organization list id' do
            expect(conversation.list_id).to eq 'UCSD Electric Racing <raceteam.127.0.0.1>'
          end
        end
      end

      context 'and there is one group' do
        let(:conversation) { threadable.conversations.find_by_slug!(single_group_conversation) }
        it 'returns the group list id' do
          expect(conversation.list_id).to eq '"UCSD Electric Racing: Electronics" <raceteam+electronics.127.0.0.1>'
        end
      end

      context 'and there are many groups' do
        let(:conversation) { threadable.conversations.find_by_slug!(multiple_group_conversation) }
        it 'returns the organization list id' do
          expect(conversation.list_id).to eq 'UCSD Electric Racing <raceteam.127.0.0.1>'
        end
      end
    end

    describe '#list_post_email_address' do
      context 'and there are no groups' do
        let(:conversation) { threadable.conversations.find_by_slug!(no_group_conversation) }
        it 'returns the organization list post address' do
          expect(conversation.list_post_email_address).to eq 'raceteam@127.0.0.1'
        end

        context 'and it is a task' do
          let(:conversation) { threadable.conversations.find_by_slug!(no_group_task) }
          it 'returns the organization list post address' do
            expect(conversation.list_post_email_address).to eq 'raceteam@127.0.0.1'
          end
        end
      end

      context 'and there is one group' do
        let(:conversation) { threadable.conversations.find_by_slug!(single_group_conversation) }
        it 'returns the group list post address' do
          expect(conversation.list_post_email_address).to eq 'raceteam+electronics@127.0.0.1'
        end
      end

      context 'and there are many groups' do
        let(:conversation) { threadable.conversations.find_by_slug!(multiple_group_conversation) }
        it 'returns the organization list post address' do
          expect(conversation.list_post_email_address).to eq 'raceteam@127.0.0.1'
        end
      end
    end

    describe '#subject_tag' do
      context 'and there are no groups' do
        let(:conversation) { threadable.conversations.find_by_slug!(no_group_conversation) }
        it 'returns the organization subject tag' do
          expect(conversation.subject_tag).to eq '[RaceTeam]'
        end

        context 'and it is a task' do
          let(:conversation) { threadable.conversations.find_by_slug!(no_group_task) }
          it 'returns the organization task subject tag' do
            expect(conversation.subject_tag).to eq "[✔\uFE0E][RaceTeam]"
          end
        end
      end

      context 'and there is one group' do
        let(:conversation) { threadable.conversations.find_by_slug!(single_group_conversation) }
        it 'returns the group subject tag' do
          expect(conversation.subject_tag).to eq '[RaceTeam+Electronics]'
        end

        context 'and it is a task' do
          let(:conversation) { threadable.conversations.find_by_slug!(single_group_task) }
          it 'returns the group task subject tag' do
            expect(conversation.subject_tag).to eq "[✔\uFE0E][RaceTeam+Electronics]"
          end
        end
      end

      context 'and there are many groups' do
        let(:conversation) { threadable.conversations.find_by_slug!(multiple_group_conversation) }
        it 'returns the organization subject tag' do
          expect(conversation.subject_tag).to eq '[RaceTeam]'
        end

        context 'and it is a task' do
          let(:conversation) { threadable.conversations.find_by_slug!(multiple_group_task) }
          it 'returns the organization task subject tag' do
            expect(conversation.subject_tag).to eq "[✔\uFE0E][RaceTeam]"
          end
        end
      end
    end

    describe '#all_email_addresses' do
      let(:conversation) { threadable.conversations.find_by_slug!(multiple_group_conversation) }
      it 'returns all the email addresses in all formats' do
        expect(conversation.all_email_addresses).to match_array [
          '"UCSD Electric Racing: Electronics" <raceteam+electronics@127.0.0.1>',
          '"UCSD Electric Racing: Fundraising" <raceteam+fundraising@127.0.0.1>',
          'raceteam+electronics@127.0.0.1',
          'raceteam+fundraising@127.0.0.1',
        ]
      end
    end
  end
end
