require 'spec_helper'

describe "organization membership roles", :type => :request do

  when_signed_in_as 'bethany@ucsd.example.com' do
    it 'the first member of an organization should be an owner' do
      threadable.organizations.all.each do |organization|
        expect(organization.members.all.first.role).to eq :owner
      end

      organization = threadable.organizations.create!(name: 'love bucket', add_current_user_as_a_member: false)
      membership = organization.members.add user: threadable.users.all.first
      expect(membership.role).to eq :owner
      membership = organization.members.add user: threadable.users.all.last
      expect(membership.role).to eq :member
    end
  end
end
