require 'spec_helper'

describe EmailAddress do

  it { should belong_to(:user) }

  it { should validate_presence_of :address }
  it { should validate_presence_of :user }
  it { should validate_uniqueness_of :address }

  it "should validate that there is only one primary email address for any one user" do
    user = User.create!(name: 'Poop Popsicle', email_address: 'poop@popsicle.io')
    user.email_addresses.first.should be_primary
    invalid_email = user.email_addresses.create(address: 'poop-popsicle@gmail.com', primary: true)
    invalid_email.errors.messages.should == {base: ["there can be only one primary email address"] }
  end

  it "should validate_format_of :address" do
    user = User.last!
    user.email_addresses.build(address:"").should_not be_valid
    user.email_addresses.build(address:"x").should_not be_valid
    user.email_addresses.build(address:"foo@bar").should_not be_valid
    user.email_addresses.build(address:"foo@bar.me").should be_valid
  end

end
