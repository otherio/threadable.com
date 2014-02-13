require 'spec_helper'

describe Threadable::Organization::Member do
  let(:organization){ threadable.organizations.find_by_slug! 'raceteam' }
  let(:member){ organization.members.find_by_email_address('bethany@ucsd.example.com') }
  subject{ member }


  context 'when signed in as an organization owner' do
    before{ sign_in_as 'alice@ucsd.example.com' }

    describe '#update' do

      context 'when updating your own role' do
        let(:member){ organization.members.find_by_email_address('alice@ucsd.example.com') }
        it 'raises a Threadable::AuthorizationError' do
          expect{ member.update(role: :member) }.to raise_error Threadable::AuthorizationError, 'You cannot change your own organization membership role'
        end
      end

      context "when updating another member's role" do
        it 'updates updates the role' do
          expect{ member.update(role: :member) }.to_not raise_error
          expect(member.role).to eq :member
        end
      end
    end

  end

  context 'when signed in as an organization member' do
    before{ sign_in_as 'tom@ucsd.example.com' }

    describe '#update' do
      context 'when updating your own role' do
        let(:member){ organization.members.find_by_email_address('alice@ucsd.example.com') }
        it 'raises a Threadable::AuthorizationError' do
          expect{ member.update(role: :member) }.to raise_error Threadable::AuthorizationError, 'You are not authorized to change organization membership roles'
        end
      end

      context "when updating another member's role" do
        it 'raises a Threadable::AuthorizationError' do
          expect{ member.update(role: :member) }.to raise_error Threadable::AuthorizationError, 'You are not authorized to change organization membership roles'
        end
      end
    end

  end

end
