require 'spec_helper'

describe Threadable::Conversations, :type => :model do

  let(:conversations){ described_class.new(threadable) }
  subject{ conversations }

  let :all_conversation_records do
    5.times.map do |i|
      double(:conversation_record, id: i, task?: (i%2==1))
    end
  end

  before do
    allow(Conversation).to receive(:order).with('conversations.updated_at DESC').and_return(all_conversation_records)
  end

  describe '#inspect' do
    subject { super().inspect }
    it { is_expected.to eq "#<Threadable::Conversations>" }
  end

  describe 'all' do
    it 'returns all the conversations' do
      all_conversation = conversations.all
      expect(all_conversation.size).to eq 5
      all_conversation.each_with_index do |conversation, i|
        expect(conversation).to be_a( (i%2==1) ? Threadable::Task : Threadable::Conversation )
        expect(conversation.conversation_record).to eq all_conversation_records[i]
      end
    end
  end

  describe 'all_with_participants' do
    it 'returns all the conversations with participants eager loaded' do
      expect(all_conversation_records).to receive(:includes).with(:participants).and_return(all_conversation_records)
      all_conversation = conversations.all_with_participants
      expect(all_conversation.size).to eq 5
      all_conversation.each_with_index do |conversation, i|
        expect(conversation).to be_a( (i%2==1) ? Threadable::Task : Threadable::Conversation )
        expect(conversation.conversation_record).to eq all_conversation_records[i]
      end
    end
  end

end
