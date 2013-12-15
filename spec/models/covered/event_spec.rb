require 'spec_helper'

describe Covered::Event do
  let(:covered) { double(:covered) }
  let(:event_record) { double(:event_record, covered: covered, type: type) }
  let(:event) { described_class.new(covered, event_record) }
  let(:type) { 'Event' }
  subject { event }

  describe '#tracking_name' do
    context 'with the Event event' do
      let(:type) { 'Event' }
      it 'returns the default' do
        expect(event.tracking_name).to eq 'Event'
      end
    end

    context 'with a named event' do
      let(:type) { 'One::MagicalThing::DerpEvent' }
      it 'returns the pretty name' do
        expect(event.tracking_name).to eq 'One Magical Thing Derp'
      end
    end
  end
end
