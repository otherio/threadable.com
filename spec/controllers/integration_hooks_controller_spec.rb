require 'spec_helper'

describe IntegrationHooksController do
  let(:organization) { threadable.organizations.find_by_slug('raceteam') }
  let(:group)        { organization.groups.find_by_slug('fundraising') }

  context 'for trello' do
    describe '#show' do
      context 'when the request is valid' do
        it 'responds to a HEAD request that the record could be found' do
          head :show, provider: 'trello', organization_id: 'raceteam', group_id: 'fundraising'
          expect(response).to be_success
          expect(response.body).to be_blank
        end
      end

      context 'when the request has an invalid organization' do
        it 'returns 410 Gone to delete the webhook' do
          head :show, provider: 'trello', organization_id: 'wrong', group_id: 'fundraising'
          expect(response.code).to eq "410"
          expect(response.body).to be_blank
        end
      end

      context 'when the request has an invalid (new) group' do
        it 'returns 410 Gone to delete the webhook' do
          head :show, provider: 'trello', organization_id: 'raceteam', group_id: 'new'
          expect(response).to be_success
          expect(response.body).to be_blank
        end
      end
    end

    describe '#create' do
      context 'when the request is valid' do
        it 'processes the params with the trello processor' do
          expect(Threadable::Integrations::TrelloProcessor).to receive(:call).with(request: request, organization: organization, group: group)
          post :create, provider: 'trello', organization_id: 'raceteam', group_id: 'fundraising'
          expect(response).to be_success
          expect(response.body).to be_blank
        end
      end

      context 'when the request has an invalid organization' do
        it 'returns 410 Gone to delete the webhook' do
          post :create, provider: 'trello', organization_id: 'wrong', group_id: 'fundraising'
          expect(response.code).to eq "410"
          expect(response.body).to be_blank
        end
      end

      context 'when the request has an invalid group' do
        it 'returns 410 Gone to delete the webhook' do
          post :create, provider: 'trello', organization_id: 'raceteam', group_id: 'wrong'
          expect(response.code).to eq "410"
          expect(response.body).to be_blank
        end
      end

    end
  end

  context 'for an unknown provider' do
    context 'when the request has a valid signature' do
      it 'fails with bad request' do
        post :create, provider: 'wrong', organization_id: 'raceteam', group_id: 'fundraising'
        expect(response).to_not be_success
        expect(response.body).to be_blank
      end
    end

  end
end
