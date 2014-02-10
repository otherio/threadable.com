require 'spec_helper'

describe Threadable::Group::Members do

  let(:organization){ threadable.organizations.find_by_slug! 'raceteam' }
  let(:group){ organization.groups.find_by_email_address_tag!('electronics') }
  let(:members){ group.members }
  subject{ members }

  describe '#all' do
    it 'returns all the members of the group as Threadable::User instances' do
      expect( members.all ).to be_a Array
      expect( members.all.first ).to be_a Threadable::User
    end
  end

  describe '#add' do
    it 'adds the given member to the group and does not send email' do
      new_member = (organization.members.all - members.all).first
      expect( members ).to_not include new_member
      members.add new_member
      expect( members ).to include new_member
      drain_background_jobs!
      expect(sent_emails).to be_empty
    end

    context 'when signed in' do
      before do
        sign_in_as 'alice@ucsd.example.com'
      end

      context 'when the user is changing their own group record' do
        let(:member) { current_user }

        it 'does not send email' do
          members.add member
          drain_background_jobs!
          expect(sent_emails).to be_empty
        end
      end

      context 'when the user is changing the membership for another user' do
        let(:member) { organization.members.find_by_email_address('bob@ucsd.example.com') }

        it 'sends email' do
          expect(member.id).to_not eq current_user.id
          members.add member
          drain_background_jobs!
          expect(sent_emails.first.subject).to include 'I added you to +Electronics on UCSD Electric Racing'
        end
      end
    end

  end

  describe '#remove' do
    it 'removes the given member from the group and does not send email' do
      member_to_remove = members.all.first
      members.remove(member_to_remove)
      expect( members ).to_not include member_to_remove
      drain_background_jobs!
      expect(sent_emails).to be_empty
    end

    context 'when signed in' do
      before do
        sign_in_as 'tom@ucsd.example.com' # a member.
      end

      context 'when the user is changing their own group record' do
        let(:member) { current_user }

        it 'does not send email' do
          members.remove member
          drain_background_jobs!
          expect(sent_emails).to be_empty
        end
      end

      context 'when the user is changing the membership for another user' do
        let(:member) { organization.members.find_by_email_address('bethany@ucsd.example.com') }

        it 'sends email' do
          expect(member.id).to_not eq current_user.id
          members.remove member
          drain_background_jobs!
          expect(sent_emails.first.subject).to include 'I removed you from +Electronics on UCSD Electric Racing'
        end
      end
    end
  end

  describe '#include?' do
    it 'returns true if the given user is in the group' do
      member_user_ids = members.all.map(&:user_id)
      organization.members.all.each do |user|
        if member_user_ids.include?(user.user_id)
          expect( members ).to include user
        else
          expect( members ).to_not include user
        end
      end
    end
  end

end
