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

end
