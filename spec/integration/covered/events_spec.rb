require 'spec_helper'

describe Covered::Events do

  let(:events){ described_class.new(covered) }
  subject{ events }

  describe 'build' do
    context 'when given no arguments' do
      it 'returns a new Covered::Event' do
        event =  events.build
        expect(event             ).to be_a ::Covered::Event
        expect(event.event_record).to be_a ::Event
      end
    end
    context 'when given an empty hash' do
      it 'returns a new Covered::Event' do
        event =  events.build({})
        expect(event             ).to be_a ::Covered::Event
        expect(event.event_record).to be_a ::Event
      end
    end
    context 'when given an unknown event type' do
      it 'raises an argument error' do
        expect{ events.build(type: "BadEvent") }.to \
          raise_error ArgumentError, %(unknown even type found in {:type=>"BadEvent"})
      end
    end
  end

  describe 'all' do
    it "returns all events" do
      all_event_records = ::Event.all
      all_events = events.all
      expect(all_events.map(&:event_record)).to eq all_event_records

      all_events.each do |event|
        expect(event).to be_a "Covered::#{event.type}".constantize
      end
    end
  end

  describe 'latest' do
    it 'returns the latest event' do
      event = events.latest
      event_record = ::Event.last
      expect(event.event_record).to eq event_record
      expect(event).to be_a "Covered::#{event_record.class}".constantize
    end
  end

  describe 'oldest' do
    it 'returns the oldest event' do
      event = events.oldest
      event_record = ::Event.first
      expect(event.event_record).to eq event_record
      expect(event).to be_a "Covered::#{event_record.class}".constantize
    end
  end

end
