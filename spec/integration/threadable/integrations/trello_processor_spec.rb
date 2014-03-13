require 'spec_helper'

describe Threadable::Integrations::TrelloProcessor do

  delegate :call, to: described_class

  let(:organization) { threadable.organizations.find_by_slug!('raceteam') }
  let(:group) { organization.groups.find_by_slug('fundraising') }

  describe '#call' do
    let(:params) do
      {
        organization: organization,
        group: group,

        integration_hook: {
          action: {
            type: action_type,
          },
          data: action_data
        }.stringify_keys
      }
    end

    context 'when the request does not have a valid signature' do
      it 'raises an exception'
    end

    describe 'new card' do
      let(:action_type) { 'createCard' }
      let(:action_data) do
        {
          list: {name: 'To Do', id: 'list_id' },
          card: {name: 'A Card', id: 'card_id' },
        }.stringify_keys
      end

      it 'makes a new conversation for the new card' do
        call(params)
        expect(group.conversations.find_by_slug('a-card')).to be
      end

    end


  end
end
