require 'spec_helper'

describe Threadable::Organization::Ungrouped do

  let(:organization){ threadable.organizations.find_by_slug! 'raceteam' }
  let(:ungrouped){ described_class.new(organization) }
  subject{ ungrouped }

   when_signed_in_as 'bethany@ucsd.example.com' do

    describe '#muted_conversations' do
      context 'when given 0' do
        it 'returns the muted_conversations for the current user' do
          expect(slugs_for subject.muted_conversations(0)).to eq [
            "get-carbon-and-fiberglass",
            "get-release-agent",
            "get-epoxy",
            "layup-body-carbon",
            "welcome-to-our-threadable-organization"
          ]
        end
      end
    end

    describe '#not_muted_conversations' do
      context 'when given 0' do
        it 'returns the not_muted_conversations for the current user' do
          expect(slugs_for subject.not_muted_conversations(0)).to eq [
            "who-wants-to-pick-up-breakfast",
            "who-wants-to-pick-up-dinner",
            "who-wants-to-pick-up-lunch",
            "make-wooden-form-for-carbon-layup",
            "trim-body-panels",
            "install-mirrors",
            "how-are-we-going-to-build-the-body"
          ]
        end
      end
    end

    describe '#done_tasks' do
      context 'when given 0' do
        it 'returns the done_tasks for the current user' do
          expect(slugs_for subject.done_tasks(0)).to eq [
            "get-epoxy",
            "get-release-agent",
            "get-carbon-and-fiberglass",
            "layup-body-carbon"
          ]
        end
      end
    end

    describe '#not_done_tasks' do
      context 'when given 0' do
        it 'returns the not_done_tasks for the current user' do
          expect(slugs_for subject.not_done_tasks(0)).to eq [
            "install-mirrors",
            "trim-body-panels",
            "make-wooden-form-for-carbon-layup"
          ]
        end
      end
    end

    describe '#done_doing_tasks' do
      context 'when given 0' do
        it 'returns the done_doing_tasks for the current user' do
          expect(slugs_for subject.done_doing_tasks(0)).to eq []
        end
      end
    end

    describe '#not_done_doing_tasks' do
      context 'when given 0' do
        it 'returns the not_done_doing_tasks for the current user' do
          expect(slugs_for subject.not_done_doing_tasks(0)).to eq []
        end
      end
    end

  end

  when_not_signed_in do
    it 'delivery_method should raise error Threadable::AuthorizationError' do
      expect{ subject.delivery_method }.to raise_error Threadable::AuthorizationError
    end
    it 'gets_no_mail? should raise error Threadable::AuthorizationError' do
      expect{ subject.gets_no_mail? }.to raise_error Threadable::AuthorizationError
    end
    it 'gets_each_message? should raise error Threadable::AuthorizationError' do
      expect{ subject.gets_each_message? }.to raise_error Threadable::AuthorizationError
    end
    it 'gets_in_summary? should raise error Threadable::AuthorizationError' do
      expect{ subject.gets_in_summary? }.to raise_error Threadable::AuthorizationError
    end
  end

  when_signed_in_as 'alice@ucsd.example.com' do
    its(:delivery_method)   { should eq :each_message }
    its(:gets_no_mail?)     { should be_false }
    its(:gets_each_message?){ should be_true  }
    its(:gets_in_summary?)  { should be_false }
  end

  when_signed_in_as 'tom@ucsd.example.com' do
    its(:delivery_method)   { should eq :no_mail }
    its(:gets_no_mail?)     { should be_true  }
    its(:gets_each_message?){ should be_false }
    its(:gets_in_summary?)  { should be_false }
  end

  when_signed_in_as 'bob@ucsd.example.com' do
    its(:delivery_method)   { should eq :in_summary }
    its(:gets_no_mail?)     { should be_false }
    its(:gets_each_message?){ should be_false }
    its(:gets_in_summary?)  { should be_true  }
  end

  when_signed_in_as 'bob@ucsd.example.com' do
    describe '#deliver_mehtod=' do
      it 'immediately updates the organization membership record' do
        record = organization.current_member.organization_membership_record
        expect(record).to_not be_changed
        expect(record.ungrouped_delivery_method).to eq :in_summary

        expect(subject.delivery_method).to eq :in_summary

        expect( subject.gets_no_mail?      ).to be_false
        expect( subject.gets_each_message? ).to be_false
        expect( subject.gets_in_summary?   ).to be_true

        subject.delivery_method = :each_message
        expect(record).to_not be_changed
        expect(record.ungrouped_delivery_method).to eq :each_message
        expect(subject.delivery_method).to eq :each_message

        expect( subject.gets_no_mail?      ).to be_false
        expect( subject.gets_each_message? ).to be_true
        expect( subject.gets_in_summary?   ).to be_false
      end
    end
  end


  def slugs_for conversations
    conversations.map(&:slug)
  end

end
