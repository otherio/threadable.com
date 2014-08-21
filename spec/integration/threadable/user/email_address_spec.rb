require 'spec_helper'

describe Threadable::User::EmailAddress, :type => :request do

  let(:user_record          ){ email_address_record.user }
  let(:email_address_records){ user_record.email_addresses }
  let(:user                 ){ Threadable::User.new(threadable, user_record) }
  let(:email_address        ){ described_class.new(user, email_address_record) }
  subject{ email_address }

  let(:email_address_record ){ find_email_address 'yan@ucsd.example.com' }

  describe '#id' do
    subject { super().id }
    it { is_expected.to eq email_address_record.id         }
  end

  describe '#address' do
    subject { super().address }
    it { is_expected.to eq email_address_record.address    }
  end

  describe '#primary?' do
    subject { super().primary? }
    it { is_expected.to eq email_address_record.primary?   }
  end

  describe '#errors' do
    subject { super().errors }
    it { is_expected.to eq email_address_record.errors     }
  end

  describe '#persisted?' do
    subject { super().persisted? }
    it { is_expected.to eq email_address_record.persisted? }
  end

  describe '#to_s' do
    subject { super().to_s }
    it { is_expected.to eq email_address.address           }
  end

  describe 'primary!' do

    context 'when the email address is primary and confirmed' do
      let(:email_address_record){ find_email_address 'yan@ucsd.example.com' }
      it 'returns false' do
        expect(email_address_record).to be_primary
        expect(email_address_record.confirmed_at).to be_present
        expect(email_address.primary!).to be_falsey
      end
    end

    context 'when the email address is not primary and not confirmed' do
      let(:email_address_record){ find_email_address 'bob.cauchois@example.com' }
      it 'returns false' do
        expect(email_address_record).to_not be_primary
        expect(email_address_record.confirmed_at).to be_nil
        expect(email_address.primary!).to be_falsey
      end
    end

    context 'when the email address is not primary but confirmed' do
      let(:email_address_record){ find_email_address 'yan@yansterdam.io' }
      it 'returns true' do
        expect(email_address_record).to_not be_primary
        expect(email_address_record.confirmed_at).to be_present
        expect(email_address.primary!).to be_truthy
      end
    end
  end

  describe 'confirm!' do
    context 'when the email address is not confirmed' do
      let(:email_address_record){ find_email_address 'bob.cauchois@example.com' }
      it 'confirmes the address' do
        expect(email_address_record.confirmed_at).to be_nil
        expect(email_address.confirm!).to be_truthy
      end
    end
    context 'when the email address is confirmed' do
      let(:email_address_record){ find_email_address 'yan@ucsd.example.com' }
      it 'does nothing' do
        expect(email_address_record.confirmed_at).to be_present
        expect(email_address.confirm!).to be_falsey
      end
    end
  end


end
