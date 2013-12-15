require 'spec_helper'

describe Covered::Events do

  let(:events){ described_class.new(covered) }
  subject{ events }

  let(:scope){ double :scope }
  before do
    Event.stub(:all).and_return(scope)
  end

  it { should have_constant :Create }

  let(:event_record){ double(:event_record) }
  let(:event){ double(:event) }

  describe 'create' do
    it 'calls Create with its self and the given attributes' do
      expect(described_class::Create).to receive(:call).with(events, some: 'attributes').and_return(event)
      expect( events.create(some: 'attributes') ).to eq event
    end
  end

  describe 'create!' do
    before{ expect(events).to receive(:create).with(my_new: 'event').and_return(event) }

    context 'when the event is saved' do
      before{ expect(event).to receive(:persisted?).and_return(true) }
      it 'return the event' do
        expect( events.create!(my_new: 'event') ).to eq event
      end
    end

    context 'when the event is not saved' do
      before do
        errors = double(:errors, full_messages: ['cannot be lame', 'cannot be stupid'])
        expect(event).to receive(:persisted?).and_return(false)
        expect(event).to receive(:errors).and_return(errors)
      end
      it 'return the event' do
        expect{ events.create!(my_new: 'event') }.to raise_error(
          Covered::RecordInvalid, "Event invalid: cannot be lame and cannot be stupid")
      end
    end
  end

end
