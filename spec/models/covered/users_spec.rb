require 'spec_helper'

describe Covered::Users do

  let(:users){ described_class.new covered }
  subject{ users }

  its(:covered){ should == covered }

  describe '#find_by_email_address' do
    let(:email_address){ 'bob@bob.com' }
    before do
      expect(User).to receive(:find_by_email_address).
        with(email_address).
        and_return(user_double)
    end
    subject{ users.find_by_email_address(email_address) }

    context "when the user is found" do
      let(:user_double){ double(:user_record, id: 12, email_address: email_address) }
      it { should be_a Covered::User }
      its(:user_record){ should == user_double }
    end

    context "when the user is not found" do
      let(:user_double){ nil }
      it { should be_nil }
    end
  end

  describe '#new' do
    subject{ users.new(name: 'Steve', email_address: 'steve@me.com') }
    it{ should be_a Covered::User }
    its(:name){ should == 'Steve' }
    its(:user_record){ should_not be_persisted }
  end

  describe '#create' do
    subject{ users.create(name: 'Steve', email_address: 'steve@me.com') }
    it{ should be_a Covered::User }
    its(:name){ should == 'Steve' }
    its(:user_record){ should be_persisted }
  end

end
