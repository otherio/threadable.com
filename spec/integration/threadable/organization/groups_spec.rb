require 'spec_helper'

describe Threadable::Organization::Groups, :type => :request do
  let(:organization){ threadable.organizations.find_by_slug! 'raceteam' }
  let(:groups){ organization.groups }
  subject{ groups }

  describe '#all' do
    context 'when not logged in' do
      it 'returns all the groups, without private groups' do
        expect(organization.groups.all.map(&:slug)).to match_array [
          "raceteam",
          "electronics",
          "fundraising",
          "graphic-design",
          "press",
        ]
      end
    end

    context 'when logged in as a member without access to private groups' do
      before do
        sign_in_as 'bethany@ucsd.example.com'
      end

      it 'returns all the groups, without private groups' do
        expect(organization.groups.all.map(&:slug)).to match_array [
          "raceteam",
          "electronics",
          "fundraising",
          "graphic-design",
          "press",
        ]
      end
    end

    context 'when logged in as a member who has access to private groups' do
      before do
        sign_in_as 'tom@ucsd.example.com'
      end

      it 'returns all the groups, including private groups' do
        expect(organization.groups.all.map(&:slug)).to match_array [
          "raceteam",
          "electronics",
          "fundraising",
          "graphic-design",
          "press",
          "leaders",
        ]
      end
    end
  end

  describe '#find_by_ids!' do
    it 'finds the groups when they exist' do
      groups_to_find = [groups.find_by_slug('electronics'), groups.find_by_slug('fundraising')]
      expect(groups.find_by_ids!(groups_to_find.map(&:id))).to match_array groups_to_find
    end

    it 'raises an error when any group is not found' do
      electronics = groups.find_by_slug('electronics')
      expect{groups.find_by_ids!([electronics.id, electronics.id + 500])}.to raise_error Threadable::RecordNotFound, 'Unable to find one of the specified groups'
    end
  end

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
        expect{ groups.find_by_email_address_tags!(email_address_tags) }.to raise_error(Threadable::RecordNotFound)
      end
    end

    context 'with no tags' do
      it 'returns an empty array' do
        email_address_tags = []
        expect( groups.find_by_email_address_tags!(email_address_tags) ).to eq []
      end
    end
  end

  describe "#auto_joinable" do
    it 'returns the groups where auto_join is true' do
      expect(groups.auto_joinable.map(&:email_address_tag)).to match_array ['raceteam', 'graphic-design']
    end
  end

  describe "#all_for_user" do
    let(:user) { organization.members.find_by_email_address('bethany@ucsd.example.com') }
    it 'returns the groups that a particular user is in' do
      expect(groups.all_for_user(user).map(&:email_address_tag)).to match_array ['raceteam', 'electronics', 'graphic-design']
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

  describe '#primary' do
    it 'returns the primary group' do
      expect(groups.primary.slug).to eq 'raceteam'
    end
  end

end
