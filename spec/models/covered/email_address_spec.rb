require 'spec_helper'

describe Covered::User::EmailAddress do

  let(:user_record){ Factories.create(:user) }
  let(:email_address_record){ user_record.email_addresses.primary }

  let(:user){ Covered::User.new(covered, user_record) }
  let(:email_address){ described_class.new(user, email_address_record) }

  subject { email_address }

  its(:covered               ){ should eq covered                   }
  its(:current_user          ){ should eq user                      }
  its(:email_address_record  ){ should eq email_address_record      }

  describe "#primary!" do
    context "when the address is already the primary email" do
      it "does not set itself to the primary email if it already is" do
        expect(user_record.email_addresses).to_not receive(:update_all).with(primary: false)
        expect(email_address_record).to_not receive(:update).with(primary: true)
        subject.primary!
      end
    end

    context "when the address is not primary" do
      before do
        user.stub(:update_mixpanel)
        email_address.stub(:primary?).and_return(false)
      end

      it "sets the primary email" do
        expect(user_record.email_addresses).to receive(:update_all).with(primary: false)
        expect(email_address_record).to receive(:update).with(primary: true)
        subject.primary!
      end

      it "updates mixpanel" do
        expect(user).to receive(:update_mixpanel)
        subject.primary!
      end
    end
  end
end
