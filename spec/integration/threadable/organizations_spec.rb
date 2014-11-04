require 'spec_helper'

describe Threadable::Organizations, :type => :request do
  let(:raceteam) { organizations.find_by_slug('raceteam') }

  let(:organizations) { threadable.organizations }

  before do
    sign_in_as 'alice@ucsd.example.com'
  end

  describe '#with_subscription' do
    before do
      raceteam.update(billforward_subscription_id: 'sub id', billforward_account_id: 'acct id')
    end

    it 'fetches the orgs that have a subscription' do
      expect(organizations.with_subscription.first.slug).to eq 'raceteam'
      expect(organizations.with_subscription.count).to eq 1
    end
  end

  describe '#with_last_message_between' do
    it 'gets the organiztions with last_message_at between two dates' do
      from = Time.parse('2014-01-01 12:00:00')
      to   = Time.parse('2014-03-01 12:00:00')

      expect(organizations.with_last_message_between(from, to).map(&:slug)).to eq ['raceteam']
    end

  end

end
