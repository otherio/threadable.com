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
      context 'but has weird non-ascii characters in it' do
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

  describe '#fuzzy_find' do
    let(:alice){ members.find_by_email_address('alice@ucsd.example.com') }

    it "finds when given a whole name" do
      expect(members.fuzzy_find("Alice Neilson")).to eq alice
    end

    it "finds when given a whole lowercase name" do
      expect(members.fuzzy_find("alice neilson")).to eq alice
    end

    it "finds when given a whole lowercase name with extra spaces" do
      expect(members.fuzzy_find(" alice  neilson  ")).to eq alice
    end

    it "finds when given an email" do
      expect(members.fuzzy_find("alice@ucsd.example.com")).to eq alice
    end

    it "returns nil when given a user who doesn't exist" do
      expect(members.fuzzy_find("Malice Neels")).to be_nil
    end

    it "returns nil when given a user who isn't in this organization" do
      expect(members.fuzzy_find("Amy Wong")).to be_nil
    end

    it "returns nil when given a blank query" do
      expect(members.fuzzy_find("")).to be_nil
    end

    it "if the query is 'me' returns the current user" do
      sign_in_as 'alice@ucsd.example.com'
      expect(members.fuzzy_find("me").id).to eq alice.id
    end

    it 'finds by the first part of a name'
  end

  describe '#find_by_name' do
    it 'when given a name for an organization member, it returns that member' do
      member = members.find_by_name('Jonathan Spray')
      expect(member).to be_present
      expect(member.name).to eq 'Jonathan Spray'
    end

    it 'when given a name for an organization member in random case, it returns that member' do
      member = members.find_by_name('JoNatHan SprAy')
      expect(member).to be_present
      expect(member.name).to eq 'Jonathan Spray'
    end

    it "when given a name for a different orgs' member, it returns nil" do
      member = members.find_by_name('Amy Wong')
      expect(member).to be_nil
    end
  end

end
