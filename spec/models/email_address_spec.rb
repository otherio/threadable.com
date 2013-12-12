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

  describe 'address format validations' do
    valid = [
      %(jared@cover.io),
      %(jared+covered@cover.io),
      %(jared@127.0.0.1),
    ]
    invalid = [
      %(\xEF\xBB\xBFjared@deadlyicon.com), # FYI this string contains a zero-width no-break space (U+FEFF)
      %(﻿jared+\xE2\x98\x83@deadlyicon.com),
      %(jared@localhost),
      # %(jared@127.0.0),
      # %(jared@127.0.0.),
    ]

    def email_address address
      described_class.new(address: address)
    end

    def self.escape_unicode string
      string.bytes.to_a.map(&:chr).join.inspect
    end

    valid.each do |address|
      it "#{escape_unicode(address)} should be valid" do
        expect(email_address(address)).to have(0).errors_on(:address)
      end
    end
    invalid.each do |address|
      it "#{escape_unicode(address)} should be invalid" do
        expect(email_address(address)).to have(1).error_on(:address)
      end
    end
  end

end
