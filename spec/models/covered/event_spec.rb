require 'spec_helper'

describe Covered::Event do
  let(:covered) { double(:covered) }
  let(:event_record) { double(:event_record, covered: covered, event_type: event_type) }
  let(:event) { described_class.new(covered, event_record) }
  let(:event_type) { :task_created }
  subject { event }

  describe '#tracking_name' do
    let(:event_type) { :task_created }
    it 'returns a human readable version of the event type' do
      expect(event.tracking_name).to eq "Task Created"
    end
  end
end
