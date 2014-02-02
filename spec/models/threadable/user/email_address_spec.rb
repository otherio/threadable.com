require 'spec_helper'

describe Threadable::User::EmailAddress do

  let(:now){ Time.now }
  before{ Time.stub now: now }

  let(:user){ double(:user, id: 4432, threadable: threadable, user_record: double(:user_record)) }
  let(:email_address_record){ double(:email_address_record, primary?: primary, confirmed?: confirmed) }
  let(:email_address){ described_class.new(user, email_address_record) }
  let(:primary){ false }
  let(:confirmed){ false }

  describe 'primary!' do
    context 'when the email address is primary but not confirmed' do
      let(:primary  ){ true }
      let(:confirmed){ false }
      it 'returns false' do
        expect(email_address.primary!).to be_false
      end
    end

    context 'when the email address is primary and confirmed' do
      let(:primary  ){ true }
      let(:confirmed){ true }
      it 'returns false' do
        expect(email_address.primary!).to be_false
      end
    end

    context 'when the email address is not primary and not confirmed' do
      let(:primary  ){ false }
      let(:confirmed){ false }
      it 'returns false' do
        expect(email_address.primary!).to be_false
      end
    end

    context 'when the email address is not primary but confirmed' do
      let(:primary  ){ false }
      let(:confirmed){ true }

      let(:email_addresses){ double(:email_addresses) }
      it 'returns true' do
        scope = double(:scope)
        expect(Threadable             ).to receive(:transaction).and_yield
        expect(EmailAddress        ).to receive(:where).with(user_id: user.id).and_return(scope)
        expect(scope               ).to receive(:update_all).with(primary: false)
        expect(email_address_record).to receive(:update).with(primary: true)
        expect(user.user_record    ).to receive(:email_addresses).and_return(email_addresses)
        expect(email_addresses     ).to receive(:reload)
        expect(user                ).to receive(:track_update!)
        expect(email_address.primary!).to be_true
      end
    end
  end

  describe 'confirm!' do
    context 'when the email address is not confirmed' do
      let(:confirmed){ false }
      it 'confirmes the address' do
        expect(email_address_record).to receive(:update!).with(confirmed_at: now)
        expect(email_address.confirm!).to be_true
      end
    end
    context 'when the email address is confirmed' do
      let(:confirmed){ true }
      it 'does nothing' do
        expect(email_address_record).to_not receive(:update!)
        expect(email_address.confirm!).to be_false
      end
    end
  end


end

