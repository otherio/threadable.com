require 'spec_helper'
require 'trello'

describe Threadable::Integrations::TrelloSetup do
  describe '#call' do

    let(:organization) { threadable.organizations.find_by_slug('raceteam') }
    let(:group) { organization.groups.find_by_slug('fundraising') }
    let(:client) { Trello.client }
    let(:board) { double(:board, id: 'board_id') }

    delegate :call, to: described_class

    when_signed_in_as 'yan@ucsd.example.com' do

      before do
        current_user.external_authorizations.add_or_update(provider: 'trello', token: 'foo', secret: 'bar')
        group.update(integration_type: 'trello', integration_params: {name: 'foo', id: 'board_id'}.to_json)
        expect(Trello::Client).to receive(:new).and_return(client)
      end

      it 'creates a webhook that points to our trello endpoint' do
        expect(client).to receive(:create).with(
          :webhook,
          'description' => 'Threadable',
          'callbackURL' => integration_hook_url(provider: 'trello', organization_id: 'raceteam', group_id: 'fundraising'),
          'idModel' => 'board_id'
        )

        call(group)
      end

      it 'replaces an existing webhook if one already exists'

    end
  end
end
