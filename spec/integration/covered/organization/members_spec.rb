require 'spec_helper'

describe Covered::Organization::Members do

  let(:organization){ covered.organizations.find_by_slug! 'raceteam' }
  let(:members){ described_class.new(organization) }

  describe 'email_addresses' do

    let :expected_email_addresses do
      %w{
        alice@ucsd.example.com
        tom@ucsd.example.com
        yan@yansterdam.io
        yan@ucsd.example.com
        bethany@ucsd.example.com
        bob@ucsd.example.com
        bob.cauchois@example.com
        jonathan@ucsd.example.com
      }.to_set
    end

    it 'returns all the email addresses for each member of the organization' do
      email_addresses = members.email_addresses
      expect(email_addresses.map(&:address).to_set).to eq expected_email_addresses
    end

  end

end
