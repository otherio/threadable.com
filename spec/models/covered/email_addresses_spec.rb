require 'spec_helper'

describe Covered::EmailAddresses do

  let(:email_addresses){ described_class.new(covered) }
  subject{ email_addresses }

  its(:covered){ should eq covered }

  let :all_email_address_records do
    3.times.map do |i|
      double(:email_address_record, id: i)
    end
  end

  describe '#all' do
    before do
      ::EmailAddress.stub_chain(:all, :to_a).and_return(all_email_address_records)
    end

    it 'returns all the email addresses as Covered::EmailAddress instances' do
      all_email_address = email_addresses.all
      expect(all_email_address.size).to eq 3
      all_email_address.each do |attachment|
        expect(attachment).to be_a Covered::EmailAddress
        expect(all_email_address_records).to include attachment.email_address_record
      end
    end
  end

  describe '#confirmed' do
    before do
      ::EmailAddress.stub_chain(:confirmed, :to_a).and_return(all_email_address_records)
    end

    it 'returns all the email addresses as Covered::EmailAddress instances' do
      confirmed_email_address = email_addresses.confirmed
      expect(confirmed_email_address.size).to eq 3
      confirmed_email_address.each do |attachment|
        expect(attachment).to be_a Covered::EmailAddress
        expect(all_email_address_records).to include attachment.email_address_record
      end
    end
  end

  describe '#unconfirmed' do
    before do
      ::EmailAddress.stub_chain(:unconfirmed, :to_a).and_return(all_email_address_records)
    end

    it 'returns all the email addresses as Covered::EmailAddress instances' do
      unconfirmed_email_address = email_addresses.unconfirmed
      expect(unconfirmed_email_address.size).to eq 3
      unconfirmed_email_address.each do |attachment|
        expect(attachment).to be_a Covered::EmailAddress
        expect(all_email_address_records).to include attachment.email_address_record
      end
    end
  end


end
