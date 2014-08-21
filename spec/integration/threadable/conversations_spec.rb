require 'spec_helper'

describe Threadable::Conversations, :type => :request do

  let(:conversations){ described_class.new(threadable) }
  subject{ conversations }

  describe '#all' do
    it 'returns all the conversations' do
      expect(conversations.all).to eq ::Conversation.order('conversations.updated_at DESC').to_a.map{|conversation_record|
        Threadable::Conversation.new(threadable, conversation_record)
      }
    end
  end

  describe '#trashed' do
    it 'returns all the conversations that are in the trash' do
      expect(conversations.trashed.map(&:slug)).to eq ['omg-i-am-so-drunk']
    end
  end

  describe '#all_with_participants' do
    it 'returns all the conversations with participants loaded' do
      expect(conversations.all_with_participants).to eq ::Conversation.order('conversations.updated_at DESC').map{|conversation_record|
        Threadable::Conversation.new(threadable, conversation_record)
      }
      conversations.all_with_participants.each do |conversation|
        expect(conversation.conversation_record.participants).to be_loaded
      end
    end
  end

  describe '#for_message_summary' do
    # get a user and stuff here, and then make this test work
    let(:date) { Time.zone.local(2014,2,2).utc }
    let(:user) { threadable.users.find_by_email_address('alice@ucsd.example.com') }
    let(:followed_conversation) { threadable.conversations.find_by_slug('get-a-new-soldering-iron') }

    before do
      Time.zone = 'US/Pacific'
      followed_conversation.follow_for user
    end

    it 'returns all the conversations updated on a particular day that the user does not follow' do
      expect(conversations.for_message_summary(user, date).map(&:slug)).to match_array [
        "drive-trains-are-expensive",
        "how-are-we-going-to-build-the-body",
        "how-are-we-paying-for-the-motor-controller",
        "inventory-led-supplies",
        "layup-body-carbon",
        "parts-for-the-drive-train",
        "parts-for-the-motor-controller",
        "who-wants-to-pick-up-breakfast",
        "who-wants-to-pick-up-dinner",
        "who-wants-to-pick-up-lunch"
      ]
    end
  end

  describe '#to_be_deleted' do
    let(:date) { Time.zone.local(2014,2,2).utc }

    let(:conversation) { conversations.find_by_slug('layup-body-carbon') }

    before do
      Time.zone = 'US/Pacific'
      conversation.conversation_record.update(trashed_at: Time.now.utc - 31.days)
    end

    it 'returns all the conversations updated on a particular day' do
      expect(conversations.to_be_deleted.map(&:slug)).to match_array ['layup-body-carbon', 'omg-i-am-so-drunk']
    end
  end

  describe '#all_with_multiple_groups' do
    let(:organization) { threadable.organizations.find_by_slug('raceteam') }
    it 'returns all the conversations in more than one group' do
      expect(organization.conversations.all_with_multiple_groups.map(&:slug)).to match_array [
        "drive-trains-are-expensive",
        "get-some-4-gauge-wire",
        "inventory-led-supplies",
      ]
    end
  end

  describe '#find_by_id' do
    context 'when given a valid id' do
      it "returns a conversation with a given id" do
        conversation_record = ::Conversation.first
        expect(conversations.find_by_id(conversation_record.id)).to eq Threadable::Conversation.new(threadable, conversation_record)
      end
    end
    context "when given an invalid id" do
      it "returns nil" do
        expect(conversations.find_by_id(234234324324432)).to be_nil
      end
    end
  end

  describe '#find_by_id!' do
    context 'when given a valid id' do
      it "returns a conversation with a given id" do
        conversation_record = ::Conversation.first
        expect(conversations.find_by_id!(conversation_record.id)).to eq Threadable::Conversation.new(threadable, conversation_record)
      end
    end
    context "when given an invalid id" do
      it "raises a Threadable::RecordNotFound" do
        expect{ conversations.find_by_id!(234234324324432) }.to raise_error(Threadable::RecordNotFound, "unable to find Conversation with id 234234324324432")
      end
    end
  end

  describe '#find_by_slug' do
    context 'when given a valid slug' do
      it "returns a conversation with a given slug" do
        conversation_record = ::Conversation.first
        expect(conversations.find_by_slug(conversation_record.slug)).to eq Threadable::Conversation.new(threadable, conversation_record)
      end
    end
    context "when given an invalid slug" do
      it "returns nil" do
        expect(conversations.find_by_slug('what-now')).to be_nil
      end
    end
  end

  describe '#find_by_slug!' do
    context 'when given a valid slug' do
      it "returns a conversation with a given slug" do
        conversation_record = ::Conversation.first
        expect(conversations.find_by_slug!(conversation_record.slug)).to eq Threadable::Conversation.new(threadable, conversation_record)
      end
    end
    context "when given an invalid slug" do
      it "returns nil" do
        expect{ conversations.find_by_slug!('what-now') }.to raise_error(Threadable::RecordNotFound, 'unable to find Conversation with slug "what-now"')
      end
    end
  end

  describe '#latest' do
    it 'returns the latest conversation' do
      expect(conversations.latest).to eq Threadable::Conversation.new(threadable, ::Conversation.order('conversations.updated_at DESC').first!)
    end
  end

  describe '#oldest' do
    it 'returns the oldest conversation' do
      expect(conversations.oldest).to eq Threadable::Conversation.new(threadable, ::Conversation.order('conversations.updated_at DESC').last!)
    end
  end

  describe '#create' do
    it 'calls Threadable::Conversations::Create.call with the given attributes' do
      attributes = double(:attributes)
      conversation = double(:conversation)
      expect(described_class::Create).to receive(:call).with(conversations, attributes).and_return(conversation)
      expect(conversations.create(attributes)).to eq conversation
    end
  end

  describe '#create!' do
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
      it 'raises a Threadable::RecordInvalid error' do
        conversation.stub_chain(:errors, :full_messages, :to_sentence).and_return("ERRORS")
        expect{ conversations.create!(attributes) }.to raise_error(Threadable::RecordInvalid, "Conversation invalid: ERRORS")
      end
    end
  end


end
