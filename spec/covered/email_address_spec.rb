require 'spec_helper'

describe Covered::EmailAddress do

  it { should belong_to(:user) }

  it { should validate_presence_of :address }
  it { should validate_presence_of :user }
  it { should validate_uniqueness_of :address }

  it "should validate that there is only one primary email address for any one user" do
    user = FactoryGirl.create(:user)
    user.email_addresses.first.should_not be_primary
    user.email_addresses.create!(address: 'myprimaryemail@imporant.org', primary: true)
    invalid_email = user.email_addresses.build(address: 'anotherpirmary@imporant.org', primary: true)
    invalid_email.should_not be_valid
    invalid_email.errors.messages.should == {base: ["there can be only one primary email address"] }
  end

  it "should validate_format_of :address" do
    user = Covered::User.last
    user.email_addresses.build(address:"").should_not be_valid
    user.email_addresses.build(address:"x").should_not be_valid
    user.email_addresses.build(address:"foo@bar").should_not be_valid
    user.email_addresses.build(address:"foo@bar.me").should be_valid
  end

end
