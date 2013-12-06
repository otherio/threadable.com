require 'spec_helper'

describe Covered::Project::Members do

  let(:project){ covered.projects.find_by_slug! 'raceteam' }
  let(:members){ described_class.new(project) }

  describe 'email_addresses' do

    let :expected_email_addresses do
      %w{
        alice@ucsd.covered.io
        tom@ucsd.covered.io
        yan@yansterdam.io
        yan@ucsd.covered.io
        bethany@ucsd.covered.io
        bob@ucsd.covered.io
        jonathan@ucsd.covered.io
      }.to_set
    end

    it 'returns all the email addresses for each member of the project' do
      email_addresses = members.email_addresses
      expect(email_addresses.map(&:address).to_set).to eq expected_email_addresses
    end

  end

end
