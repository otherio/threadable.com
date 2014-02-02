require 'spec_helper'

describe Covered::Organization::Groups::Create do
  let(:organization){ covered.organizations.find_by_slug! 'raceteam' }

  describe '#call' do
    context 'with the auto_join flag set to true' do
      it 'adds all the current members to the group' do
        group = organization.groups.create(name: 'foo', auto_join: true)
        expect(group.members.count).to eq 6
      end
    end

    context 'with the auto_join flag set to false' do
      it 'adds all the current members to the group' do
        group = organization.groups.create(name: 'foo', auto_join: false)
        expect(group.members.count).to eq 0
      end
    end

    context 'with the auto_join flag unset' do
      it 'adds all the current members to the group' do
        group = organization.groups.create(name: 'foo')
        expect(group.members.count).to eq 6
      end
    end
  end
end
