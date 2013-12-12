require 'spec_helper'

describe Covered::Project::Members do
  let(:project){ covered.projects.find_by_slug('raceteam') }
  let(:members){ described_class.new(project) }

  describe '#find_by_email_address' do

    context "when given an email address for a member we have" do
      it 'returns that member' do
        member = members.find_by_email_address('jonathan@ucsd.covered.io')
        expect(member).to be_present
        expect(member.name).to eq 'Jonathan Spray'
      end
      context 'but has weird none-ascii characters in it' do
        it 'returns that member' do
          member = members.find_by_email_address("\xEF\xBB\xBFjonathan@ucsd.covered.io")
          expect(member).to be_present
          expect(member.name).to eq 'Jonathan Spray'
        end
      end
    end

    context "when given an email address for a member we have" do
      it 'returns that member' do
        member = members.find_by_email_address('lisa@ucsd.covered.io')
        expect(member).to be_nil
      end
    end

  end

end
