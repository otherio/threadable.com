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


  describe "conversation groups" do
    it "should be in sync" do
      all_conversations = organization.conversations.all.map do |conversation|
        [conversation, conversation.groups.all]
      end

      all_groups = organization.groups.all.map do |group|
        [group, group.conversations.all]
      end

      all_conversations.each do |conversation, groups|
        all_groups.each do |group, conversations|
          if groups.include? group
            expect(conversations).to include conversation
          else
            expect(conversations).to_not include conversation
          end
        end
      end

      all_groups.each do |group, conversations|
        all_conversations.each do |conversation, groups|
          if conversations.include? conversation
            expect(groups).to include group
          else
            expect(groups).to_not include group
          end
        end
      end

    end
  end

end
