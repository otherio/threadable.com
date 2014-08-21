require 'spec_helper'

describe Threadable::EmailAddresses, :type => :model do

  let(:email_addresses){ described_class.new(threadable) }
  subject{ email_addresses }

  describe '#threadable' do
    subject { super().threadable }
    it { is_expected.to eq threadable }
  end

  let :all_email_address_records do
    3.times.map do |i|
      double(:email_address_record, id: i)
    end
  end

  describe '#all' do
    before do
      ::EmailAddress.stub_chain(:all, :to_a).and_return(all_email_address_records)
    end

    it 'returns all the email addresses as Threadable::EmailAddress instances' do
      all_email_address = email_addresses.all
      expect(all_email_address.size).to eq 3
      all_email_address.each do |attachment|
        expect(attachment).to be_a Threadable::EmailAddress
        expect(all_email_address_records).to include attachment.email_address_record
      end
    end
  end

  describe '#confirmed' do
    before do
      ::EmailAddress.stub_chain(:confirmed, :to_a).and_return(all_email_address_records)
    end

    it 'returns all the email addresses as Threadable::EmailAddress instances' do
      confirmed_email_address = email_addresses.confirmed
      expect(confirmed_email_address.size).to eq 3
      confirmed_email_address.each do |attachment|
        expect(attachment).to be_a Threadable::EmailAddress
        expect(all_email_address_records).to include attachment.email_address_record
      end
    end
  end

  describe '#unconfirmed' do
    before do
      ::EmailAddress.stub_chain(:unconfirmed, :to_a).and_return(all_email_address_records)
    end

    it 'returns all the email addresses as Threadable::EmailAddress instances' do
      unconfirmed_email_address = email_addresses.unconfirmed
      expect(unconfirmed_email_address.size).to eq 3
      unconfirmed_email_address.each do |attachment|
        expect(attachment).to be_a Threadable::EmailAddress
        expect(all_email_address_records).to include attachment.email_address_record
      end
    end
  end

  describe '#find_or_create_by_address!' do
    it 'finds or creates an email address by the lower case version of the given address' do
      a = email_addresses.find_or_create_by_address!('foo@bar.com')
      b = email_addresses.find_or_create_by_address!('foo@bar.com')
      expect(a.id).to eq b.id
    end
  end

end
