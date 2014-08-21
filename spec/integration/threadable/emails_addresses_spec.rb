require 'spec_helper'

describe Threadable::EmailAddresses, :type => :request do

  let(:email_addresses){ described_class.new(threadable) }
  subject{ email_addresses }

  describe '#threadable' do
    subject { super().threadable }
    it { is_expected.to eq threadable }
  end

  let :email_address_strings do
    [
      'sadsa@asdsadsa.com',
      'jared@other.io',
      'JARED@OTHER.IO',
      'bob@ucsd.example.com',
      'BOB@UCSD.EXAMPLE.COM',
    ]
  end

  describe '#find_by_address' do
    it 'returns the first matching email address for the given address' do

      results = email_address_strings.map do |email_address_string|
        email_addresses.find_by_address(email_address_string)
      end

      expect( results[0] ).to be_nil
      expect( results[1] ).to be_a Threadable::EmailAddress
      expect( results[2] ).to be_a Threadable::EmailAddress
      expect( results[3] ).to be_a Threadable::EmailAddress
      expect( results[4] ).to be_a Threadable::EmailAddress
      expect( results[3] ).to eq results[4]
    end
  end

  describe '#find_by_addresses' do
    it 'returns an array of the matching email addresses for the given address strings, in the same order' do
      results = email_addresses.find_by_addresses(email_address_strings)

      expect( results[0] ).to be_nil
      expect( results[1] ).to be_a Threadable::EmailAddress
      expect( results[2] ).to be_a Threadable::EmailAddress
      expect( results[3] ).to be_a Threadable::EmailAddress
      expect( results[4] ).to be_a Threadable::EmailAddress
      expect( results[3] ).to eq results[4]

    end
  end

end
