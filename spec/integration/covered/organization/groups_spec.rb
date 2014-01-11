require 'spec_helper'

describe Covered::Organization::Groups do
  let(:organization){ covered.organizations.find_by_slug! 'raceteam' }
  let(:groups){ organization.groups }
  subject{ groups }

  describe '#find_by_email_address_tags' do

    context 'when given valid group email address tags' do
      it 'returns an identically ordered array with the matching group and or nil' do
        email_address_tags = ['electronics', 'fundraising', 'missing-group']
        expect( groups.find_by_email_address_tags(email_address_tags) ).to eq [
          groups.find_by_email_address_tag!('electronics'),
          groups.find_by_email_address_tag!('fundraising'),
          nil
        ]
      end
    end

    context 'with no tags' do
      it 'returns an empty array' do
        email_address_tags = []
        expect( groups.find_by_email_address_tags(email_address_tags) ).to eq []
      end
    end
  end

  describe '#find_by_email_address_tags!' do

    context 'when given valid group email address tags' do
      it 'returns an identically ordered array with the matching groups' do
        email_address_tags = ['electronics', 'fundraising']
        expect( groups.find_by_email_address_tags!(email_address_tags) ).to eq [
          groups.find_by_email_address_tag!('electronics'),
          groups.find_by_email_address_tag!('fundraising'),
        ]
      end
    end

    context 'when given an invalid email address tag' do
      it 'raises an exception' do
        email_address_tags = ['electronics', 'fundraising', 'missing-group']
        expect{ groups.find_by_email_address_tags!(email_address_tags) }.to raise_error(Covered::RecordNotFound)
      end
    end

    context 'with no tags' do
      it 'returns an empty array' do
        email_address_tags = []
        expect( groups.find_by_email_address_tags!(email_address_tags) ).to eq []
      end
    end
  end

end
