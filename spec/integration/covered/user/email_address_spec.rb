require 'spec_helper'

describe Covered::User::EmailAddress do

  let(:user_record          ){ email_address_record.user }
  let(:email_address_records){ user_record.email_addresses }
  let(:user                 ){ Covered::User.new(covered, user_record) }
  let(:email_address        ){ described_class.new(user, email_address_record) }
  subject{ email_address }

  let(:email_address_record ){ find_email_address 'yan@ucsd.covered.io' }

  its(:id        ){ should eq email_address_record.id         }
  its(:address   ){ should eq email_address_record.address    }
  its(:primary?  ){ should eq email_address_record.primary?   }
  its(:errors    ){ should eq email_address_record.errors     }
  its(:persisted?){ should eq email_address_record.persisted? }
  its(:to_s      ){ should eq email_address.address           }

  describe 'primary!' do
    context 'when the email address is primary' do
      let(:email_address_record){ find_email_address 'yan@ucsd.covered.io' }
      it 'returns false' do
        expect(email_address_record).to be_primary
        expect(email_address.primary!).to be_false
        expect(email_address_record).to be_primary
      end
    end
    context 'when the email address is not primary' do
      let(:email_address_record){ find_email_address 'yan@yansterdam.io' }
      it 'returns true' do
        expect(email_address_record).to_not be_primary
        expect(email_address.primary!).to be_true
        expect(email_address_record).to be_primary
        expect(user_record.email_addresses.primary).to eq [email_address_record]
      end
    end
  end

end
