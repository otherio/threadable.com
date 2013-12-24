require 'spec_helper'

describe Covered::Organization::Members do
  let(:organization){ covered.organizations.find_by_slug('raceteam') }
  let(:members){ described_class.new(organization) }

  describe '#find_by_email_address' do

    context "when given an email address for a member we have" do
      it 'returns that member' do
        member = members.find_by_email_address('jonathan@ucsd.example.com')
        expect(member).to be_present
        expect(member.name).to eq 'Jonathan Spray'
      end
      context 'but has weird none-ascii characters in it' do
        it 'returns that member' do
          member = members.find_by_email_address("\xEF\xBB\xBFjonathan@ucsd.example.com")
          expect(member).to be_present
          expect(member.name).to eq 'Jonathan Spray'
        end
      end
    end

    context "when given an email address for a member we have" do
      it 'returns that member' do
        member = members.find_by_email_address('lisa@ucsd.example.com')
        expect(member).to be_nil
      end
    end

  end

end
