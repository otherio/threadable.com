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
    it 'adds the given member to the group' do
      new_member = (organization.members.all - members.all).first
      expect( members ).to_not include new_member
      members.add new_member
      expect( members ).to include new_member
    end
  end

  describe '#remove' do
    it 'removes the given member from the group' do
      member_to_remove = members.all.first
      members.remove(member_to_remove)
      expect( members ).to_not include member_to_remove
    end
  end

  describe '#include?' do
    it 'returns true if the given user is in the group' do
      group_member_user_ids = members.all.map(&:user_id)
      organization.members.all.each do |group_member|
        if group_member_user_ids.include? group_member.user_id
          expect( members ).to include group_member
        else
          expect( members ).to_not include group_member
        end
      end
    end
  end

end
