require 'spec_helper'

describe Threadable::User::EmailAddresses do
  describe '#for_domain' do
    let(:bob) { threadable.users.find_by_email_address('bob@ucsd.example.com') }

    before do
      bob.email_addresses.add('foo@bar.com', primary: false)
    end

    it 'gets an email address that matches the supplied domain' do
      expect(bob.email_addresses.for_domain('bar.com').address).to eq 'foo@bar.com'
      expect(bob.email_addresses.for_domain('ucsd.example.com').address).to eq 'bob@ucsd.example.com'
    end

    it 'returns the primary email address when no other address matches' do
      expect(bob.email_addresses.for_domain('foo.com').address).to eq 'bob@ucsd.example.com'
    end
  end
end
