require 'spec_helper'

describe Threadable::Organizations, :type => :request do

  describe '#with_subscription' do
    let(:raceteam) { threadable.organizations.find_by_slug('raceteam') }
    before do
      sign_in_as 'alice@ucsd.example.com'
      raceteam.update(billforward_subscription_id: 'sub id', billforward_account_id: 'acct id')
    end

    it 'fetches the orgs that have a subscription' do
      expect(threadable.organizations.with_subscription.first.slug).to eq 'raceteam'
      expect(threadable.organizations.with_subscription.count).to eq 1
    end
  end

end
