require 'spec_helper'

describe Covered::User::EmailAddress do

  let(:user_record          ){ email_address_record.user }
  let(:email_address_records){ user_record.email_addresses }
  let(:user                 ){ Covered::User.new(covered, user_record) }
  let(:email_address        ){ described_class.new(user, email_address_record) }
  subject{ email_address }

  let(:email_address_record ){ find_email_address 'yan@ucsd.example.com' }

  its(:id        ){ should eq email_address_record.id         }
  its(:address   ){ should eq email_address_record.address    }
  its(:primary?  ){ should eq email_address_record.primary?   }
  its(:errors    ){ should eq email_address_record.errors     }
  its(:persisted?){ should eq email_address_record.persisted? }
  its(:to_s      ){ should eq email_address.address           }

  describe 'primary!' do

    context 'when the email address is primary and confirmed' do
      let(:email_address_record){ find_email_address 'yan@ucsd.example.com' }
      it 'returns false' do
        expect(email_address_record).to be_primary
        expect(email_address_record.confirmed_at).to be_present
        expect(email_address.primary!).to be_false
      end
    end

    context 'when the email address is not primary and not confirmed' do
      let(:email_address_record){ find_email_address 'bob.cauchois@example.com' }
      it 'returns false' do
        expect(email_address_record).to_not be_primary
        expect(email_address_record.confirmed_at).to be_nil
        expect(email_address.primary!).to be_false
      end
    end

    context 'when the email address is not primary but confirmed' do
      let(:email_address_record){ find_email_address 'yan@yansterdam.io' }
      it 'returns true' do
        expect(email_address_record).to_not be_primary
        expect(email_address_record.confirmed_at).to be_present
        expect(email_address.primary!).to be_true
      end
    end
  end

  describe 'confirm!' do
    context 'when the email address is not confirmed' do
      let(:email_address_record){ find_email_address 'bob.cauchois@example.com' }
      it 'confirmes the address' do
        expect(email_address_record.confirmed_at).to be_nil
        expect(email_address.confirm!).to be_true
      end
    end
    context 'when the email address is confirmed' do
      let(:email_address_record){ find_email_address 'yan@ucsd.example.com' }
      it 'does nothing' do
        expect(email_address_record.confirmed_at).to be_present
        expect(email_address.confirm!).to be_false
      end
    end
  end


end
