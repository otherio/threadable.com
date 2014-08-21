# encoding: UTF-8
require 'spec_helper'

describe EmailAddress, type: :model, fixtures: false do

  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of :address }
  it { is_expected.to validate_uniqueness_of :address }

  it "should validate that there is only one primary email address for any one user" do
    user = User.create!(name: 'Poop Popsicle', email_address: 'poop@popsicle.io')
    expect(user.email_addresses.first).to be_primary
    invalid_email = user.email_addresses.create(address: 'poop-popsicle@gmail.com', primary: true)
    expect(invalid_email.errors.messages).to eq({base: ["there can be only one primary email address"] })
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
      described_class.create(address: address)
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
          expect(email_address(address).errors[:address].size).to eq(0)
        end
      end
    end

    invalid_addresses.each do |address|
      context "when given the address #{escape_unicode(address)}" do
        it 'should be invalid' do
          expect(email_address(address).errors[:address].size).to eq(1)
        end
      end
    end
  end

end
