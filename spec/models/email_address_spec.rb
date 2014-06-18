# encoding: UTF-8
require 'spec_helper'

describe EmailAddress, fixtures: false do

  it { should belong_to(:user) }
  it { should validate_presence_of :address }
  it { should validate_uniqueness_of :address }

  it "should validate that there is only one primary email address for any one user" do
    user = User.create!(name: 'Poop Popsicle', email_address: 'poop@popsicle.io')
    user.email_addresses.first.should be_primary
    invalid_email = user.email_addresses.create(address: 'poop-popsicle@gmail.com', primary: true)
    invalid_email.errors.messages.should == {base: ["there can be only one primary email address"] }
  end

  describe '#confirmed' do
    it "can find confirmed/unconfirmed email addresses using scopes" do
      user = User.create!(name: 'Poop Popsicle', email_address: 'poop@popsicle.io')
      email = user.email_addresses.first
      expect(email).to be_primary
      expect(user.email_addresses.unconfirmed.first).to eq email
      email.update(confirmed_at: Time.now)
      expect(user.email_addresses.confirmed.first).to eq email
    end
  end

  describe 'address format validations' do

    def email_address address
      described_class.new(address: address)
    end

    def self.escape_unicode string
      string.bytes.to_a.map(&:chr).join.inspect
    end

    valid_addresses = [
      %(jared@cover.io),
      %(jared+threadable@cover.io),
      %(jared@127.0.0.1),
      %(\xEF\xBB\xBFjared@deadlyicon.com), # FYI this string contains a zero-width no-break space (U+FEFF)
      %(jared+\xE2\x98\x83@deadlyicon.com),
      %(jared@localhost),
    ]

    invalid_addresses = [
      %(jared),
      %(jared@),
      %(amazon.com),
      %(ian.baker@foo),
    ]

    valid_addresses.each do |address|
      context "when given the address #{escape_unicode(address)}" do
        it "should be valid" do
          expect(email_address(address)).to have(0).errors_on(:address)
        end
      end
    end

    invalid_addresses.each do |address|
      context "when given the address #{escape_unicode(address)}" do
        it 'should be invalid' do
          expect(email_address(address)).to have(1).errors_on(:address)
        end
      end
    end
  end

end
