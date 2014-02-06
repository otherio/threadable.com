require 'spec_helper'

describe Threadable::User::Organization::Ungrouped do

  subject{ described_class.new(organization) }

  when_signed_in_as 'bethany@ucsd.example.com' do

    describe "#gets_no_mail!" do
      it 'delgated to organization_membership_record.gets_no_ungrouped_conversation_mail!' do
        # expect(organization_membership_record).to receive(:gets_no_ungrouped_conversation_mail!).and_return(5)
        # expect(subject.gets_no_mail!).to eq 5
      end
    end

    describe "#gets_messages!" do
      it 'delgated to organization_membership_record.gets_ungrouped_conversation_messages!' do
        # expect(organization_membership_record).to receive(:gets_ungrouped_conversation_messages!).and_return(5)
        # expect(subject.gets_messages!).to eq 5
      end
    end

    describe "#gets_in_summary!" do
      it 'delgated to organization_membership_record.gets_ungrouped_conversations_in_summary!' do
        # expect(organization_membership_record).to receive(:gets_ungrouped_conversations_in_summary!).and_return(5)
        # expect(subject.gets_in_summary!).to eq 5
      end
    end

    describe "#gets_no_mail?" do
      it 'delgated to organization_membership_record.gets_no_ungrouped_conversation_mail?' do
        # expect(organization_membership_record).to receive(:gets_no_ungrouped_conversation_mail?).and_return(5)
        # expect(subject.gets_no_mail?).to eq 5
      end
    end

    describe "#gets_messages?" do
      it 'delgated to organization_membership_record.gets_ungrouped_conversation_messages?' do
        # expect(organization_membership_record).to receive(:gets_ungrouped_conversation_messages?).and_return(5)
        # expect(subject.gets_messages?).to eq 5
      end
    end

    describe "#gets_in_summary?" do
      it 'delgated to organization_membership_record.gets_ungrouped_conversations_in_summary?' do
        # expect(organization_membership_record).to receive(:gets_ungrouped_conversations_in_summary?).and_return(5)
        # expect(subject.gets_in_summary?).to eq 5
      end
    end

  end

end
