require 'spec_helper'

describe Covered::Conversations do

  let(:conversations){ described_class.new(covered) }
  subject{ conversations }

  let :all_conversation_records do
    5.times.map do |i|
      double(:conversation_record, id: i, task?: (i%2==1))
    end
  end

  before do
    ::Conversation.stub(all: all_conversation_records)
  end

  its(:inspect){ should eq "#<Covered::Conversations>" }

  describe 'all' do
    it 'returns all the conversations' do
      all_conversation = conversations.all
      expect(all_conversation.size).to eq 5
      all_conversation.each_with_index do |conversation, i|
        expect(conversation).to be_a( (i%2==1) ? Covered::Task : Covered::Conversation )
        expect(conversation.conversation_record).to eq all_conversation_records[i]
      end
    end
  end

  describe 'all_with_participants' do
    it 'returns all the conversations with participants eager loaded' do
      expect(Conversation.all).to receive(:includes).with(:participants).and_return(all_conversation_records)
      all_conversation = conversations.all_with_participants
      expect(all_conversation.size).to eq 5
      all_conversation.each_with_index do |conversation, i|
        expect(conversation).to be_a( (i%2==1) ? Covered::Task : Covered::Conversation )
        expect(conversation.conversation_record).to eq all_conversation_records[i]
      end
    end
  end

  describe 'find_by_id' do
    it 'needs tests'
  end

  describe 'find_by_id' do
    it 'needs tests'
  end

  describe 'find_by_slug' do
    it 'needs tests'
  end

  describe 'find_by_slug' do
    it 'needs tests'
  end

  describe 'newest' do
    it 'needs tests'
  end

  describe 'oldest' do
    it 'needs tests'
  end


end
