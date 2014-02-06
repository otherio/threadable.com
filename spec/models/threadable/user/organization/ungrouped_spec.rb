require 'spec_helper'

describe Threadable::User::Organization::Ungrouped do

  let(:organization_record){ double :organization_record }
  let(:organization_membership_record){ double :organization_membership_record }
  let(:user){ double :user }
  let(:organization){ double :organization, threadable: threadable, organization_record: organization_record, user: user }

  subject{ described_class.new(organization) }

  before do
    organization.stub_chain(:membership, :organization_membership_record).and_return(organization_membership_record)
  end

  its(:threadable)         { should be threadable }
  its(:organization)       { should be organization }
  its(:organization_record){ should be organization_record }

  describe "#gets_no_mail!" do
    it 'delgated to organization_membership_record.gets_no_ungrouped_conversation_mail!' do
      expect(organization_membership_record).to receive(:gets_no_ungrouped_conversation_mail!).and_return(5)
      expect(subject.gets_no_mail!).to eq 5
    end
  end

  describe "#gets_messages!" do
    it 'delgated to organization_membership_record.gets_ungrouped_conversation_messages!' do
      expect(organization_membership_record).to receive(:gets_ungrouped_conversation_messages!).and_return(5)
      expect(subject.gets_messages!).to eq 5
    end
  end

  describe "#gets_in_summary!" do
    it 'delgated to organization_membership_record.gets_ungrouped_conversations_in_summary!' do
      expect(organization_membership_record).to receive(:gets_ungrouped_conversations_in_summary!).and_return(5)
      expect(subject.gets_in_summary!).to eq 5
    end
  end

  describe "#gets_no_mail?" do
    it 'delgated to organization_membership_record.gets_no_ungrouped_conversation_mail?' do
      expect(organization_membership_record).to receive(:gets_no_ungrouped_conversation_mail?).and_return(5)
      expect(subject.gets_no_mail?).to eq 5
    end
  end

  describe "#gets_messages?" do
    it 'delgated to organization_membership_record.gets_ungrouped_conversation_messages?' do
      expect(organization_membership_record).to receive(:gets_ungrouped_conversation_messages?).and_return(5)
      expect(subject.gets_messages?).to eq 5
    end
  end

  describe "#gets_in_summary?" do
    it 'delgated to organization_membership_record.gets_ungrouped_conversations_in_summary?' do
      expect(organization_membership_record).to receive(:gets_ungrouped_conversations_in_summary?).and_return(5)
      expect(subject.gets_in_summary?).to eq 5
    end
  end

end
