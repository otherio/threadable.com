require 'spec_helper'

describe Covered::Conversation do

  let(:conversation_record){ double(:conversation_record, id: 2323, task?: false) }
  subject{ described_class.new(covered, conversation_record) }

  it { should have_constant :Creator      }
  it { should have_constant :Events       }
  it { should have_constant :Event        }
  it { should have_constant :CreatedEvent }
  it { should have_constant :Messages     }
  it { should have_constant :Recipients   }
  it { should have_constant :Recipient    }
  it { should have_constant :Participants }
  it { should have_constant :Participant  }


  it { should delegate(:id         ).to(:conversation_record) }
  it { should delegate(:to_param   ).to(:conversation_record) }
  it { should delegate(:slug       ).to(:conversation_record) }
  it { should delegate(:subject    ).to(:conversation_record) }
  it { should delegate(:task?      ).to(:conversation_record) }
  it { should delegate(:created_at ).to(:conversation_record) }
  it { should delegate(:updated_at ).to(:conversation_record) }
  it { should delegate(:persisted? ).to(:conversation_record) }
  it { should delegate(:new_record?).to(:conversation_record) }
  it { should delegate(:errors     ).to(:conversation_record) }


  its(:creator     ){ should be_a Covered::Conversation::Creator      }
  its(:events      ){ should be_a Covered::Conversation::Events       }
  its(:messages    ){ should be_a Covered::Conversation::Messages     }
  its(:recipients  ){ should be_a Covered::Conversation::Recipients   }
  its(:participants){ should be_a Covered::Conversation::Participants }


  describe 'update' do
    it 'should call update_attributes on the conversation record' do
      attributes = double(:attributes)
      expect(conversation_record).to receive(:update_attributes).with(attributes).and_return(4)
      expect(subject.update(attributes)).to be_true
    end
  end

  describe 'update!' do
    let(:attributes){ double(:attributes) }
    context 'when the update is successful' do
      before{ expect(subject).to receive(:update).with(attributes).and_return(true) }
      it 'should return true' do
        expect(subject.update!(attributes)).to be_true
      end
    end
    context 'when the update is successful' do
      before{ expect(subject).to receive(:update).with(attributes).and_return(false) }
      it 'should return true' do
        errors = double(:errors, full_messages: ['e1', 'e2'])
        expect(conversation_record).to receive(:errors).and_return(errors)
        expect{ subject.update!(attributes) }.to raise_error Covered::RecordInvalid, 'Conversation invalid: e1 and e2'
      end
    end
  end

  describe 'as_json' do
    before do
      subject.stub(
        id:         'STUBBED ID',
        to_param:   'STUBBED TO_PARAM',
        slug:       'STUBBED SLUG',
        task?:      'STUBBED TASK?',
        created_at: 'STUBBED CREATED_AT',
        updated_at: 'STUBBED UPDATED_AT',
      )
    end
    its :as_json do
      should eq(
        id:         subject.id,
        param:      subject.to_param,
        slug:       subject.slug,
        task:       subject.task?,
        created_at: subject.created_at,
        updated_at: subject.updated_at,
      )
    end
  end

  its(:inspect){ should eq "#<Covered::Conversation conversation_id: 2323>" }
end