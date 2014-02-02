require 'spec_helper'

describe Threadable::Events do

  let(:events){ described_class.new(threadable) }
  subject{ events }

  it { should have_constant :Create }

  let(:event_record){ double(:event_record) }
  let(:event){ double(:event) }

  describe 'create' do
    it 'called Threadable::Events::Create.call' do
      expect(described_class::Create).to receive(:call).with(events, :task_created, {user_id: 33}).and_return(event)
      expect(events.create(:task_created, user_id: 33)).to be event
    end
  end

  describe 'create!' do
    before{ expect(events).to receive(:create).with(:task_created, my_new: 'event').and_return(event) }

    context 'when the event is saved' do
      before{ expect(event).to receive(:persisted?).and_return(true) }
      it 'return the event' do
        expect( events.create!(:task_created, my_new: 'event') ).to eq event
      end
    end

    context 'when the event is not saved' do
      before do
        errors = double(:errors, full_messages: ['cannot be lame', 'cannot be stupid'])
        expect(event).to receive(:persisted?).and_return(false)
        expect(event).to receive(:errors).and_return(errors)
      end
      it 'return the event' do
        expect{ events.create!(:task_created, my_new: 'event') }.to raise_error(
          Threadable::RecordInvalid, "Event invalid: cannot be lame and cannot be stupid")
      end
    end
  end

end
