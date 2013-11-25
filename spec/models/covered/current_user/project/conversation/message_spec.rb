require 'spec_helper'

describe Covered::CurrentUser::Project::Conversation::Message do

  describe 'model_name' do
    subject {described_class.model_name}
    it { should == ::Message.model_name }
  end


  let(:conversation) { double(:conversation) }
  let :message_record do
    double(:message_record, id: 234213)
  end
  subject{ described_class.new(conversation, message_record) }


  %w{
    id
    unique_id
    to_param
    from
    subject
    message_id_header
    references_header
    shareworthy?
    knowledge?
    html?
    created_at
    persisted?
    errors
    body_html
    body_plain
    stripped_html
    stripped_plain
  }.each do |delegated_method|
    it "delegates #{delegated_method} to message_record" do
      expect(subject).to delegate(delegated_method).to(:message_record)
    end
  end

  describe "body" do
    it "returns an instance of Body" do
      subject.stub(body_html: 'THE HTML', body_plain: 'THE TEXT VERSION')
      expect(described_class::Body).to receive(:call).with('THE HTML', 'THE TEXT VERSION')
      subject.body
    end
  end

  describe "stripped_body" do
    it "returns an instance of Body" do
      subject.stub(stripped_html: 'THE HTML', stripped_plain: 'THE TEXT VERSION')
      expect(described_class::Body).to receive(:call).with('THE HTML', 'THE TEXT VERSION')
      subject.stripped_body
    end
  end

  describe "root?" do
    it "should indicate whether the parent_message is present" do
      subject.stub(parent_message: nil)
      expect(subject.root?).to be_true
      subject.stub(parent_message: double(:message))
      expect(subject.root?).to be_false
    end
  end

  describe "as_json" do
    it "should look like this" do
      subject.stub(
        id:             "ID STUB",
        to_param:       "TO_PARAM STUB",
        subject:        "SUBJECT STUB",
        body:           "BODY STUB",
        stripped_body:  "STRIPPED_BOD STUB",
        root?:          "ROOT? STUB",
        shareworthy?:   "SHAREWORTHY? STUB",
        knowledge?:     "KNOWLEDGE? STUB",
        created_at:     "CREATED_AT STUB",
      )
      expect(subject.as_json).to eq(
        id:             "ID STUB",
        param:          "TO_PARAM STUB",
        subject:        "SUBJECT STUB",
        body:           "BODY STUB",
        stripped_body:  "STRIPPED_BOD STUB",
        root:           "ROOT? STUB",
        shareworthy:    "SHAREWORTHY? STUB",
        knowledge:      "KNOWLEDGE? STUB",
        created_at:     "CREATED_AT STUB",
      )
    end
  end


  describe 'parent_message' do
    context 'when the parent message is present' do
      before{ message_record.stub(parent_message_id: 55) }
      it "returns the parent message" do
        subject.stub conversation: double(:conversation, messages: double(:messages))
        parent_message_double = double(:parent_message)
        expect(subject.conversation.messages).to receive(:find_by_id!).once.with(55).and_return(parent_message_double)
        expect(subject.parent_message).to eq parent_message_double
        expect(subject.parent_message).to eq parent_message_double
      end
    end

    context 'when the parent message is not present' do
      before{ message_record.stub(parent_message_id: nil) }
      it "returns nil" do
        expect(subject.parent_message).to be_nil
      end
    end
  end

  describe 'creator' do
    context 'when the parent message is present' do
      before{ message_record.stub(creator_id: 55) }
      it "returns the parent message" do
        subject.stub project: double(:project, members: double(:members))
        creator_double = double(:creator)
        expect(subject.project.members).to receive(:find_by_user_id!).once.with(55).and_return(creator_double)
        expect(subject.creator).to eq creator_double
        expect(subject.creator).to eq creator_double
      end
    end

    context 'when the parent message is not present' do
      before{ message_record.stub(creator_id: nil) }
      it "returns nil" do
        expect(subject.creator).to be_nil
      end
    end
  end

  describe 'recipients' do
    it "should return all the members of the project that get email" do
      subject.stub project: double(:project, members: double(:members))
      members_double = double(:members_that_get_email)
      expect(subject.project.members).to receive(:that_get_email).and_return(members_double)
      expect(subject.recipients).to eq members_double
    end
  end

  describe 'attachments' do
    it "returns an instance of Attachments for this message" do
      attachments_double = double(:attachments)
      expect(Covered::CurrentUser::Project::Conversation::Message::Attachments).to receive(:new).once.with(subject).and_return(attachments_double)
      expect(subject.attachments).to eq attachments_double
      expect(subject.attachments).to eq attachments_double
    end
  end

  describe 'update' do
    it "delegates the given attributes to message_record.update_attributes" do
      expect(message_record).to receive(:update_attributes).with(something: 'awesome')
      subject.update something: 'awesome'
    end
  end

  describe '==' do
    it "uses its class and its id to define equality" do
      other = described_class.new(conversation, message_record)
      expect(subject == other).to be_true

      other = described_class.new(conversation, double(:message_record, id: 444))
      expect(subject == other).to be_false
    end
  end

  its(:inspect){ should == %(#<#{described_class}>)}

end
