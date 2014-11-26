require 'spec_helper'

describe Threadable::InMemoryTracker, :type => :model do
  let(:threadable_with_tracking_id) do
    Threadable.new(
      host: threadable.host,
      port: threadable.port,
      protocol: threadable.protocol,
      worker: threadable.worker,
      tracking_id: 5
    )
  end

  let(:tracker) { described_class.new(threadable_with_tracking_id) }

  it 'needs more tests'

  describe '#increment_for_user' do
    it 'increments multiple properties' do
      tracker.set_properties_for_user(5, foo: 1, bar: 2)
      tracker.increment_for_user(5, foo: 1, bar: 1)
      expect(tracker.people[5]).to eq({foo: 2, bar: 3})
    end

    it 'increments undefined properties' do
      tracker.increment_for_user(5, foo: 1, bar: 1)
      expect(tracker.people[5]).to eq({foo: 1, bar: 1})
    end
  end

  describe '#increment' do
    it 'increments a property for the current user' do
      tracker.set_properties(foo: 1)
      tracker.increment(foo: 1)
      expect(tracker.people[5]).to eq({foo: 2})
    end
  end

  describe '#track_user_change' do
    let(:user) do
      double(:user,
        id: 5,
        name: 'Foo Guy',
        email_address: 'foo@bar.com',
        created_at: Time.now,
        organization_owner: true,
        munge_reply_to?: false,
        web_enabled?: true,
      )
    end

    it 'updates the user record in mixpanel' do
      tracker.track_user_change user
      expect(tracker.people[5]).to eq({
        '$user_id'       => 5,
        '$name'          => 'Foo Guy',
        '$email'         => 'foo@bar.com',
        '$created'       => user.created_at.iso8601,
        'Owner'          => true,
        'Web Enabled'    => true,
        'Munge Reply-to' => false,
      })
    end
  end

  describe '#refresh_user_record' do
    let(:user) do
      double(:user,
        id: 5,
        name: 'Foo Guy',
        email_address: 'foo@bar.com',
        created_at: Time.now,
        organization_owner: true,
        munge_reply_to?: false,
        web_enabled?: true,
        messages: double(:messages, count: 25)
      )
    end

    it 'updates the user record in mixpanel, and also refreshes all counters' do
      tracker.refresh_user_record user
      expect(tracker.people[5]).to eq({
        '$user_id'          => 5,
        '$name'             => 'Foo Guy',
        '$email'            => 'foo@bar.com',
        '$created'          => user.created_at.iso8601,
        '$ignore_time'      => true,
        'Owner'             => true,
        'Web Enabled'       => true,
        'Munge Reply-to'    => false,
        'Composed Messages' => 25,
      })
    end
  end

end
