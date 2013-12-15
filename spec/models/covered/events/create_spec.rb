require 'spec_helper'

describe Covered::Events::Create do

  let(:event) { double :event }
  let(:event_record) { double :event_record }
  let(:events) { double :events, covered: covered }
  let(:covered) { double :covered }
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
