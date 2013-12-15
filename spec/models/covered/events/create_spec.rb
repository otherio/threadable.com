require 'spec_helper'

describe Covered::Events::Create do

  let(:event_persisted) { true }
  let(:event) { double :event, persisted?: event_persisted, tracking_name: 'Event' }
  let(:event_record) { double :event_record, persisted?: event_persisted }
  let(:events) { double :events, covered: covered }
  let(:covered) { double :covered, track: double(:track) }
  let(:scope) { double :scope, create: event_record }

  let(:create_event) { described_class.call(events, event_attributes) }
  subject{ create_event }

  let(:event_attributes) do
    {
      type: 'Event',
      project_id: 1
    }
  end

  before do
    expect(Event).to receive(:create!).with(event_attributes).and_return(event_record)
  end

  context "with a valid event type" do
    before do
      expect(Covered::Event).to receive(:new).with(covered, event_record).and_return(event)
    end

    it 'makes a new event' do
      expect(create_event).to eq event
    end

    it 'tracks the event' do
      expect(covered).to receive(:track).with('Event', {project_id: 1} )
      create_event
    end
  end

  context 'when the event fails to save' do
    let(:event_persisted) { false }
    it 'does not track the event' do
      expect(covered).to_not receive(:track)
      create_event
    end
  end

  context "with an invalid event type" do
    before do
      expect(Covered::Event).to receive(:new).with(covered, event_record).and_raise(ActiveRecord::SubclassNotFound)
    end

    it 'raises an ArgumentError' do
      expect{create_event}.to raise_error(ArgumentError)
    end
  end

end
