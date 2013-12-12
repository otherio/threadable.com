require 'spec_helper'

describe Covered::SignUp, fixtures: false do

  let(:name                 ){ 'Thomas Shaffer' }
  let(:email_address        ){ 'thomas@shaffer.me' }
  let(:password             ){ 'password' }
  let(:password_confirmation){ 'password' }

  let :attributes do
    {
      name:                  name,
      email_address:         email_address,
      password:              password,
      password_confirmation: password_confirmation,
    }
  end

  let(:user){ described_class.call(covered, attributes) }

  it 'creates a user' do
    expect(user).to be_persisted
    expect(user).to be_valid
  end

  context 'when given an email address with non-ascii characters' do
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

    def self.escape_unicode string
      string.bytes.to_a.map(&:chr).join.inspect
    end

    valid.each do |address|
      it "#{escape_unicode(address)} should return a persisted user" do
        attributes[:email_address] = address
        expect(user).to be_persisted
      end
    end
    invalid.each do |address|
      it "#{escape_unicode(address)} should return a unpersisted user" do
        attributes[:email_address] = address
        expect(user).to_not be_persisted
        expect(user.errors['email_addresses.address']).to eq ['is invalid']
      end
    end
  end
end
