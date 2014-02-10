require 'spec_helper'

describe Threadable::Organization::Members::Add do

  let(:organization){ threadable.organizations.find_by_slug! 'raceteam' }
  let(:member_to_add) { threadable.users.find_by_email_address('amywong.phd@gmail.com') }

  describe '#call' do
    let(:auto_join_group) { organization.groups.find_by_email_address_tag('graphic-design') }
    let(:non_auto_join_group) { organization.groups.find_by_email_address_tag('electronics') }
    it 'adds the member to auto-joinable groups, but not non-auto-joinable groups' do
      organization.members.add(email_address: 'amywong.phd@gmail.com')

      expect( auto_join_group.members.all     .map(&:user_id) ).to     include member_to_add.user_id
      expect( non_auto_join_group.members.all .map(&:user_id) ).to_not include member_to_add.user_id
    end
  end

end
