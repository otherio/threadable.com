require 'spec_helper'

describe Covered::Conversations do

  let(:conversations){ described_class.new(covered) }
  subject{ conversations }

  describe 'all' do
    it 'returns all the conversations' do
      expect(conversations.all).to eq ::Conversation.order('conversations.updated_at DESC').to_a.map{|conversation_record|
        Covered::Conversation.new(covered, conversation_record)
      }
    end
  end

  describe 'all_with_participants' do
    it 'returns all the conversations with participants loaded' do
      expect(conversations.all_with_participants).to eq ::Conversation.order('conversations.updated_at DESC').map{|conversation_record|
        Covered::Conversation.new(covered, conversation_record)
      }
      conversations.all_with_participants.each do |conversation|
        expect(conversation.conversation_record.participants).to be_loaded
      end
    end
  end

  describe 'find_by_id' do
    context 'when given a valid id' do
      it "returns a conversation with a given id" do
        conversation_record = ::Conversation.first
        expect(conversations.find_by_id(conversation_record.id)).to eq Covered::Conversation.new(covered, conversation_record)
      end
    end
    context "when given an invalid id" do
      it "returns nil" do
        expect(conversations.find_by_id(234234324324432)).to be_nil
      end
    end
  end

  describe 'find_by_id!' do
    context 'when given a valid id' do
      it "returns a conversation with a given id" do
        conversation_record = ::Conversation.first
        expect(conversations.find_by_id!(conversation_record.id)).to eq Covered::Conversation.new(covered, conversation_record)
      end
    end
    context "when given an invalid id" do
      it "raises a Covered::RecordNotFound" do
        expect{ conversations.find_by_id!(234234324324432) }.to raise_error(Covered::RecordNotFound, "unable to find Conversation with id 234234324324432")
      end
    end
  end

  describe 'find_by_slug' do
    context 'when given a valid slug' do
      it "returns a conversation with a given slug" do
        conversation_record = ::Conversation.first
        expect(conversations.find_by_slug(conversation_record.slug)).to eq Covered::Conversation.new(covered, conversation_record)
      end
    end
    context "when given an invalid slug" do
      it "returns nil" do
        expect(conversations.find_by_slug('what-now')).to be_nil
      end
    end
  end

  describe 'find_by_slug!' do
    context 'when given a valid slug' do
      it "returns a conversation with a given slug" do
        conversation_record = ::Conversation.first
        expect(conversations.find_by_slug!(conversation_record.slug)).to eq Covered::Conversation.new(covered, conversation_record)
      end
    end
    context "when given an invalid slug" do
      it "returns nil" do
        expect{ conversations.find_by_slug!('what-now') }.to raise_error(Covered::RecordNotFound, 'unable to find Conversation with slug "what-now"')
      end
    end
  end

  describe 'latest' do
    it 'returns the latest conversation' do
      expect(conversations.latest).to eq Covered::Conversation.new(covered, ::Conversation.order('conversations.updated_at DESC').first!)
    end
  end

  describe 'oldest' do
    it 'returns the oldest conversation' do
      expect(conversations.oldest).to eq Covered::Conversation.new(covered, ::Conversation.order('conversations.updated_at DESC').last!)
    end
  end

  describe 'create' do
    it 'calls Covered::Conversations::Create.call with the given attributes' do
      attributes = double(:attributes)
      conversation = double(:conversation)
      expect(described_class::Create).to receive(:call).with(conversations, attributes).and_return(conversation)
      expect(conversations.create(attributes)).to eq conversation
    end
  end

  describe 'create!' do
    let(:attributes){ double(:attributes) }
    before{ expect(conversations).to receive(:create).with(attributes).and_return(conversation) }
    context 'when create returns a persisted conversation' do
      let(:conversation){ double(:conversation, persisted?: true) }
      it 'returns the conversation' do
        expect(conversations.create!(attributes)).to eq conversation
      end
    end
    context 'when create returns a not persisted conversation' do
      let(:conversation){ double(:conversation, persisted?: false) }
      it 'raises a Covered::RecordInvalid error' do
        conversation.stub_chain(:errors, :full_messages, :to_sentence).and_return("ERRORS")
        expect{ conversations.create!(attributes) }.to raise_error(Covered::RecordInvalid, "Conversation invalid: ERRORS")
      end
    end
  end


end