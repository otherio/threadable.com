require 'spec_helper'

describe Covered::Project::Conversation do

  let(:project){ double(:project) }
  let(:conversation_record){ double(:conversation_record, id: 2323) }
  subject{ Covered::Project::Conversation.new(project, conversation_record) }

  %w{
    Creator
    Events
    Event
    CreatedEvent
    Messages
    Message
    Recipients
    Recipient
    Participants
    Participant
  }.each do |constant|
    describe "::#{constant}" do
      specify{ "#{described_class}::#{constant}".constantize.name.should == "#{described_class}::#{constant}" }
    end
  end

  %w{
    id
    to_param
    slug
    subject
    task?
    created_at
    updated_at
    persisted?
    new_record?
    errors
  }.each do |method_name|
    it { should delegate(method_name).to(:conversation_record) }
  end

  its(:creator     ){ should be_a Covered::Project::Conversation::Creator      }
  its(:events      ){ should be_a Covered::Project::Conversation::Events       }
  its(:messages    ){ should be_a Covered::Project::Conversation::Messages     }
  its(:recipients  ){ should be_a Covered::Project::Conversation::Recipients   }
  its(:participants){ should be_a Covered::Project::Conversation::Participants }


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

  its(:inspect){ should eq "#<Covered::Project::Conversation conversation_id: 2323>" }
end
