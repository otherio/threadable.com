require 'spec_helper'

describe Threadable::IncomingIntegrationHook do

  let(:organization ){ threadable.organizations.find_by_slug!('raceteam') }
  let(:group        ){ organization.groups.find_by_slug('fundraising') }
  let(:request      ){ nil }
  let(:incoming_integration_hook){ threadable.incoming_integration_hooks.create!(organization, group, request, params) }
  subject{ incoming_integration_hook }

  let(:params) do
    {
      'external_conversation_id' => 'EXTERNAL_CONVERSATION_ID',
      'external_message_id' => 'EXTERNAL_MESSAGE_ID',
      'params' => {hi: 'there'},
      'provider' => provider
    }
  end

  describe 'process!' do
    let(:provider) { 'trello' }
    it 'calls the correct processor class' do
      expect(Threadable::Integrations::TrelloProcessor).to receive(:call).with(incoming_integration_hook)
      incoming_integration_hook.process!
      expect(incoming_integration_hook).to be_processed
    end
  end
end
