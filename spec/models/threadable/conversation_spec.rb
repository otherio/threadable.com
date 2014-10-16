require 'spec_helper'

describe Threadable::Conversation, :type => :model do

  let(:conversation_record){ double(:conversation_record, id: 2323, task?: false, creator_id: 8993, organization: organization_record) }
  let(:organization_record) { double(:organization_record)}
  let(:conversation){ described_class.new(threadable, conversation_record) }
  subject{ conversation }

  it { is_expected.to have_constant :Creator      }
  it { is_expected.to have_constant :Events       }
  it { is_expected.to have_constant :Messages     }
  it { is_expected.to have_constant :Recipients   }
  it { is_expected.to have_constant :Participants }
  it { is_expected.to have_constant :Participant  }


  it { is_expected.to delegate(:id              ).to(:conversation_record) }
  it { is_expected.to delegate(:to_param        ).to(:conversation_record) }
  it { is_expected.to delegate(:slug            ).to(:conversation_record) }
  it { is_expected.to delegate(:subject         ).to(:conversation_record) }
  it { is_expected.to delegate(:task?           ).to(:conversation_record) }
  it { is_expected.to delegate(:messages_count  ).to(:conversation_record) }
  it { is_expected.to delegate(:organization_id ).to(:conversation_record) }
  it { is_expected.to delegate(:creator_id      ).to(:conversation_record) }
  it { is_expected.to delegate(:created_at      ).to(:conversation_record) }
  it { is_expected.to delegate(:updated_at      ).to(:conversation_record) }
  it { is_expected.to delegate(:persisted?      ).to(:conversation_record) }
  it { is_expected.to delegate(:new_record?     ).to(:conversation_record) }
  it { is_expected.to delegate(:errors          ).to(:conversation_record) }
  it { is_expected.to delegate(:last_message_at ).to(:conversation_record) }
  it { is_expected.to delegate(:trashed_at      ).to(:conversation_record) }

  describe '#creator' do
    subject { super().creator }
    it { is_expected.to be_a Threadable::Conversation::Creator      }
  end

  describe '#events' do
    subject { super().events }
    it { is_expected.to be_a Threadable::Conversation::Events       }
  end

  describe '#messages' do
    subject { super().messages }
    it { is_expected.to be_a Threadable::Conversation::Messages     }
  end

  describe '#recipients' do
    subject { super().recipients }
    it { is_expected.to be_a Threadable::Conversation::Recipients   }
  end

  describe '#participants' do
    subject { super().participants }
    it { is_expected.to be_a Threadable::Conversation::Participants }
  end


  describe 'update' do
    let(:organization){ double(:organization) }

    before do
      expect(Threadable::Organization).to receive(:new).and_return(organization)

      expect(conversation).to receive(:private?).and_return(true)
      expect(conversation).to receive(:private_permitted_user_ids).and_return([42,43])
      expect(organization).to receive(:application_update).with({
        action:          :update,
        target:          :conversation,
        target_record:   conversation,
        serializer:      :base_conversations,
        user_ids:        [42,43],
      })
    end

    it 'should call update_attributes on the conversation record' do
      attributes = double(:attributes)
      expect(conversation_record).to receive(:update_attributes).with(attributes).and_return(4)
      expect(subject.update(attributes, true)).to be_truthy
    end
  end

  describe 'update!' do
    let(:attributes){ double(:attributes) }
    context 'when the update is successful' do
      before{ expect(subject).to receive(:update).with(attributes).and_return(true) }
      it 'should return true' do
        expect(subject.update!(attributes)).to be_truthy
      end
    end
    context 'when the update is successful' do
      before{ expect(subject).to receive(:update).with(attributes).and_return(false) }
      it 'should return true' do
        errors = double(:errors, full_messages: ['e1', 'e2'])
        expect(conversation_record).to receive(:errors).and_return(errors)
        expect{ subject.update!(attributes) }.to raise_error Threadable::RecordInvalid, 'Conversation invalid: e1 and e2'
      end
    end
  end

  it "should have tests for participant_names that expect the new code jared and ian wrote one day in a hurry"
  # describe 'participant_names' do
  #   let(:messages){ double(:messages) }
  #   let(:creator){ double(:creator, name: 'Nicole Aptekar') }
  #   let :all_messages do
  #     [
  #       double(:message, creator: double(:creator, name: 'Jared Grippe'), from: 'Jared Grippe <jared@other.io>'),
  #       double(:message, creator: nil, from: 'Peter Sellers <peter.sellers@example.com>'),
  #       double(:message, creator: double(:creator, name: 'Jared Grippe'), from: 'Martin Van Buren <martin@example.com>'),
  #       double(:message, creator: nil, from: nil),
  #     ]
  #   end
  #   before do
  #     expect(conversation).to receive(:messages).and_return(messages)
  #     conversation.stub creator: creator
  #     expect(messages).to receive(:all).and_return(all_messages)
  #   end

  #   it 'returns an array of strings' do
  #     expect(conversation.participant_names).to eq ['Jared', 'Peter']
  #   end
  #   context "when there are no messages" do
  #     let(:all_messages){ [] }
  #     it 'returns an array with one string of the creator name' do
  #       expect(conversation.participant_names).to eq ['Nicole']
  #     end
  #   end
  # end

  describe '#inspect' do
    subject { super().inspect }
    it { is_expected.to eq "#<Threadable::Conversation conversation_id: 2323>" }
  end
end
