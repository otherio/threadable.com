require 'spec_helper'

describe Threadable::IncomingIntegrationHooks do

  let(:raceteam      ){ threadable.organizations.find_by_slug!('raceteam') }
  let(:alice         ){ raceteam.members.find_by_integration_hooks_address!('alice@ucsd.example.com') }

  let(:params) do
    {
      'provider' => 'trello',
      'foo' => 'bar',
    }
  end

  describe 'create!' do
    it 'makes a record and enqueues the processing job' do
      hook = threadable.incoming_integration_hooks.create!(params)
      expect(hook.params).to eq {'foo' => 'bar'}
      expect(job).to 'be in a queue or something'
    end

  end
end
