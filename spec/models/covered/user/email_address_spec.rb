require 'spec_helper'

describe Covered::User::EmailAddress do

  let(:user){ double(:user, id: 4432, covered: covered, user_record: double(:user_record)) }
  let(:email_address_record){ double(:email_address_record, primary?: primary) }
  let(:email_address){ described_class.new(user, email_address_record) }
  let(:primary){ false }


  describe 'primary!' do
    context 'when the email address is primary' do
      let(:primary){ true }
      it 'returns false' do
        expect(email_address.primary!).to be_false
      end
    end
    context 'when the email address is not primary' do
      let(:primary){ false }
      let(:email_addresses){ double(:email_addresses) }
      it 'returns true' do
        scope = double(:scope)
        expect(EmailAddress        ).to receive(:transaction).and_yield
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


end

