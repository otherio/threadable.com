require 'spec_helper'

describe Threadable::Events, :type => :request do

  let(:events){ described_class.new(threadable) }
  subject{ events }

  describe 'all' do
    it "returns all events" do
      all_event_records = ::Event.all
      all_events = events.all
      expect(all_events.map(&:event_record)).to eq all_event_records

      all_events.each do |event|
        expect(event).to be_a "Threadable::Events::#{event.event_type.to_s.camelize}".constantize
      end
    end
  end

  describe 'latest' do
    it 'returns the latest event' do
      event = events.latest
      event_record = ::Event.last
      expect(event.event_record).to eq event_record
      expect(event).to be_a "Threadable::Events::#{event.event_type.to_s.camelize}".constantize
    end
  end

  describe 'oldest' do
    it 'returns the oldest event' do
      event = events.oldest
      event_record = ::Event.first
      expect(event.event_record).to eq event_record
      expect(event).to be_a "Threadable::Events::#{event.event_type.to_s.camelize}".constantize
    end
  end

  describe '#create', fixtures: false do

    let(:organization){ FactoryGirl.create :organization }

    context 'when given an empty event type' do
      it 'raises an ArgumentError' do
        expect{ events.create(nil, organization: organization) }.to raise_error ArgumentError, 'event type required'
        expect{ events.create("", organization: organization) }.to raise_error ArgumentError, 'event type required'
      end
    end

    context 'when given an invalid event type' do
      it 'raises an ArgumentError' do
        expect{ events.create('freebird', organization: organization) }.to raise_error ArgumentError, 'invalid event type: "freebird"'
        expect{ events.create(:freebird, organization: organization)  }.to raise_error ArgumentError, 'invalid event type: "freebird"'
      end
    end

    context 'when given a valid event type' do
      it 'returns an instance of that event type subclass' do
        event = events.create('conversation_created', organization: organization)
        expect(event).to be_persisted
        expect(event.event_type).to eq :conversation_created
        expect(event).to be_a Threadable::Events::ConversationCreated

        event = events.create(:task_added_doer, organization: organization)
        expect(event).to be_persisted
        expect(event.event_type).to eq :task_added_doer
        expect(event).to be_a Threadable::Events::TaskAddedDoer
      end
    end

    context "when given virtual attributes" do
      it 'serialized them in the content hash' do
        event = events.create(:task_added_doer, organization: organization, doer_id: 42)
        expect(event).to be_persisted
        expect(event).to be_a Threadable::Events::TaskAddedDoer
        expect(event.doer_id).to eq 42
      end
    end

  end

end
