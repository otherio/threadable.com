require 'spec_helper'

describe Threadable::Organization::Members do

  let(:organization){ threadable.organizations.find_by_slug! 'raceteam' }
  let(:members){ described_class.new(organization) }

  describe 'email_addresses' do

    let :expected_email_addresses do
      %w{
        alice@ucsd.example.com
        tom@ucsd.example.com
        yan@yansterdam.io
        yan@ucsd.example.com
        nadya@ucsd.example.com
        bethany@ucsd.example.com
        bob@ucsd.example.com
        bob.cauchois@example.com
        jonathan@ucsd.example.com
        ricky.bobby@ucsd.example.com
        cal.naughton@ucsd.example.com
        lilith@sfhealth.example.com
      }
    end

    it 'returns all the email addresses for each member of the organization' do
      email_addresses = members.email_addresses
      expect(email_addresses.map(&:address)).to match_array expected_email_addresses
    end

  end

  describe '#who_are_owners' do
    let(:alice) { organization.members.find_by_email_address('alice@ucsd.example.com') }
    it 'returns all the org owners' do
      expect(members.who_are_owners).to eq [alice]
    end
  end

end
