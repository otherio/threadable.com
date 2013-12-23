require 'spec_helper'

describe Covered::EmailAddress do

  let :email_address_record do
    double(:email_address_record,
      id: 3390,
      address: 'foo@bar.io',
      primary?: true,
      confirmed?: true,
      errors: nil,
      user_id: 1,
    )
  end

  let(:email_address){ described_class.new(covered, email_address_record) }
  subject{ email_address }

  it { should delegate(:id        ).to(:email_address_record) }
  it { should delegate(:address   ).to(:email_address_record) }
  it { should delegate(:primary?  ).to(:email_address_record) }
  it { should delegate(:errors    ).to(:email_address_record) }
  it { should delegate(:persisted?).to(:email_address_record) }
  it { should delegate(:confirmed?).to(:email_address_record) }

  its(:covered             ){ should eq covered }
  its(:email_address_record){ should eq email_address_record }
  its(:inspect             ){ should eq %(#<Covered::EmailAddress address: "foo@bar.io", primary: true, confirmed: true>) }
  its(:to_s                ){ should eq 'foo@bar.io' }

  its(:formatted_email_address) { should eq 'foo@bar.io'}

  describe '#formatted_email_address' do
    before do
      email_address.stub(:user).and_return(double(:user, name: 'Foo Bar'))
      email_address.stub(:address).and_return('foo@bar.io')
    end

    its(:formatted_email_address) { should eq 'Foo Bar <foo@bar.io>'}
  end
end
