require 'spec_helper'

describe Threadable::IncomingIntegrationHooks do

  let(:organization ){ threadable.organizations.find_by_slug!('raceteam') }
  let(:group        ){ organization.groups.find_by_slug('fundraising') }
  let(:request      ){ nil }

  let(:params) do
    {
      'provider' => 'trello',
      'foo' => 'bar',
    }
  end

  describe 'create!' do
    it 'makes a record and enqueues the processing job' do
      expect(ProcessIncomingIntegrationHookWorker).to receive(:perform_async)
      hook = threadable.incoming_integration_hooks.create!(organization, group, request, params)
      expect(hook.params).to eq({'provider'=>'trello', 'foo' => 'bar'})
    end

  end
end
