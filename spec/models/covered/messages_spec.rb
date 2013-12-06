require 'spec_helper'

describe Covered::Messages do

  let(:messages){ described_class.new(covered) }
  subject{ messages }

  let(:scope){ double :scope }
  before do
    Message.stub(:all).and_return(scope)
  end

  it { should have_constant :Create }
  it { should have_constant :FindByChildHeader }

  let(:message_record){ double(:message_record) }
  let(:message){ double(:message) }

  describe 'all' do
    it 'returns all messages' do
      all_message_records = [1,2,3]
      expect(scope).to receive(:reload).and_return(all_message_records)
      expect(Covered::Message).to receive(:new).with(covered, 1).and_return(1)
      expect(Covered::Message).to receive(:new).with(covered, 2).and_return(2)
      expect(Covered::Message).to receive(:new).with(covered, 3).and_return(3)
      expect(messages.all).to eq [1,2,3]
    end
  end

  describe 'latest' do
    it 'returns the latest message' do
      expect(scope).to receive(:last).and_return(message_record)
      expect(Covered::Message).to receive(:new).with(covered, message_record).and_return(message)
      expect(messages.latest).to eq message

      expect(scope).to receive(:last).and_return(nil)
      expect(Covered::Message).to_not receive(:new)
      expect(messages.latest).to be_nil
    end
  end

  describe 'oldest' do
    it 'returns the oldest message' do
      expect(scope).to receive(:first).and_return(message_record)
      expect(Covered::Message).to receive(:new).with(covered, message_record).and_return(message)
      expect(messages.oldest).to eq message

      expect(scope).to receive(:last).and_return(nil)
      expect(Covered::Message).to_not receive(:new)
      expect(messages.latest).to be_nil
    end
  end

  describe 'find_by_id' do
    it 'return the message for the given id' do
      expect(scope).to receive(:find).with(84).and_return(message_record)
      expect(Covered::Message).to receive(:new).with(covered, message_record).and_return(message)
      expect(messages.find_by_id(84)).to eq message

      expect(scope).to receive(:find).with(84).and_return(nil)
      expect(Covered::Message).to_not receive(:new)
      expect(messages.find_by_id(84)).to be_nil
    end
  end

  describe 'find_by_id!' do
    context 'when the message is found' do
      before{ expect(messages).to receive(:find_by_id).with(66).and_return(message) }
      it 'return the message' do
        expect( messages.find_by_id!(66) ).to eq message
      end
    end
    context 'when the message is not found' do
      before{ expect(messages).to receive(:find_by_id).with(66).and_return(nil) }
      it 'raises a Covered::RecordNotFound error' do
        expect{ messages.find_by_id!(66) }.to raise_error(
          Covered::RecordNotFound, 'unable to find conversation message with id: 66')
      end
    end
  end

  describe 'find_by_message_id_header' do
    it 'return the message for the given message id header' do
      expect(scope).to receive(:where).twice.with(message_id_header: '<oooo@o.com>').and_return(scope)
      expect(scope).to receive(:first).and_return(message_record)
      expect(Covered::Message).to receive(:new).with(covered, message_record).and_return(message)
      expect(messages.find_by_message_id_header('<oooo@o.com>')).to eq message

      expect(scope).to receive(:first).and_return(nil)
      expect(Covered::Message).to_not receive(:new)
      expect(messages.find_by_message_id_header('<oooo@o.com>')).to be_nil
    end
  end

  describe 'find_by_message_id_header!' do
    context 'when the message is found' do
      before{ expect(messages).to receive(:find_by_message_id_header).with('<xxxx@x.com>').and_return(message) }
      it 'return the message' do
        expect( messages.find_by_message_id_header!('<xxxx@x.com>') ).to eq message
      end
    end
    context 'when the message is not found' do
      before{ expect(messages).to receive(:find_by_message_id_header).with('<xxxx@x.com>').and_return(nil) }
      it 'raises a Covered::RecordNotFound error' do
        expect{ messages.find_by_message_id_header!('<xxxx@x.com>') }.to raise_error(
          Covered::RecordNotFound, 'unable to find conversation message message id header: <xxxx@x.com>')
      end
    end
  end

  describe 'build' do
    it 'returns a new message' do
      expect(scope).to receive(:build).with(foo: 'bar').and_return(message_record)
      expect(Covered::Message).to receive(:new).with(covered, message_record).and_return(message)
      expect(messages.build(foo: 'bar')).to eq message
    end
  end

  describe 'create' do
    it 'calls Create with its self and the given attributes' do
      expect(described_class::Create).to receive(:call).with(messages, some: 'attributes').and_return(message)
      expect( messages.create(some: 'attributes') ).to eq message
    end
  end

  describe 'create!' do
    before{ expect(messages).to receive(:create).with(my_new: 'message').and_return(message) }
    context 'when the message is saved' do
      before{ expect(message).to receive(:persisted?).and_return(true) }
      it 'return the message' do
        expect( messages.create!(my_new: 'message') ).to eq message
      end
    end
    context 'when the message is not saved' do
      before do
        errors = double(:errors, full_messages: ['cannot be lame', 'cannot be stupid'])
        expect(message).to receive(:persisted?).and_return(false)
        expect(message).to receive(:errors).and_return(errors)
      end
      it 'return the message' do
        expect{ messages.create!(my_new: 'message') }.to raise_error(
          Covered::RecordInvalid, "Message invalid: cannot be lame and cannot be stupid")
      end
    end
  end



end
