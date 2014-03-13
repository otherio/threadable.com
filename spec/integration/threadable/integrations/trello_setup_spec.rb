require 'spec_helper'
require 'trello'

describe Threadable::Integrations::TrelloSetup do
  describe '#call' do

    let(:organization) { threadable.organizations.find_by_slug('raceteam') }
    let(:group) { organization.groups.find_by_slug('fundraising') }
    let(:user_client) { Trello.client }
    let(:threadable_client) { Trello.client }
    let(:board) { double(:board, id: 'board_id') }

    delegate :call, to: described_class

    when_signed_in_as 'yan@ucsd.example.com' do

      before do
        current_user.external_authorizations.add_or_update(provider: 'trello', token: 'foo', secret: 'bar')
        group.update(integration_type: 'trello', integration_params: {name: 'foo', id: 'board_id'}.to_json)
        expect(Trello::Client).to receive(:new).and_return(user_client)
        expect(Trello::Client).to receive(:new).and_return(threadable_client)
      end

      it 'adds our trello user to the board, and creates a webhook' do
        expect(user_client).to receive(:find).and_return(board)
        expect(board).to receive(:add_member).with(email: 'support@threadable.com', name: 'Threadable').and_return(board)

        expect(threadable_client).to receive(:create).with(
          :webhook,
          description: 'Threadable',
          callback_url: integration_hook_url(provider: 'trello', organization_id: 'raceteam', group_id: 'fundraising'),
          id_model: 'board_id'
        )

        call(group)
      end

      it 'still works when the threadable member was already invited' do
        expect(user_client).to receive(:find).and_return(board)
        expect(board).to receive(:add_member).with(email: 'support@threadable.com', name: 'Threadable').and_raise(Trello::Error, "Member already invited\n")

        expect(threadable_client).to receive(:create).with(
          :webhook,
          description: 'Threadable',
          callback_url: integration_hook_url(provider: 'trello', organization_id: 'raceteam', group_id: 'fundraising'),
          id_model: 'board_id'
        )

        call(group)
      end

      it 'creates a webhook that points to our trello endpoint'

      it 'replaces an existing webhook if one already exists'

    end
  end
end
