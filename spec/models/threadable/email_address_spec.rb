require 'spec_helper'

describe Threadable::EmailAddress, :type => :model do

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

  let(:email_address){ described_class.new(threadable, email_address_record) }
  subject{ email_address }

  it { is_expected.to delegate(:id        ).to(:email_address_record) }
  it { is_expected.to delegate(:primary?  ).to(:email_address_record) }
  it { is_expected.to delegate(:errors    ).to(:email_address_record) }
  it { is_expected.to delegate(:persisted?).to(:email_address_record) }
  it { is_expected.to delegate(:confirmed?).to(:email_address_record) }

  describe '#threadable' do
    subject { super().threadable }
    it { is_expected.to eq threadable }
  end

  describe '#email_address_record' do
    subject { super().email_address_record }
    it { is_expected.to eq email_address_record }
  end

  describe '#inspect' do
    subject { super().inspect }
    it { is_expected.to eq %(#<Threadable::EmailAddress address: "foo@bar.io", primary: true, confirmed: true>) }
  end

  describe '#to_s' do
    subject { super().to_s }
    it { is_expected.to eq 'foo@bar.io' }
  end

  describe '#formatted_email_address' do
    subject { super().formatted_email_address }
    it { is_expected.to eq 'foo@bar.io'}
  end

  describe '#formatted_email_address' do
    before do
      allow(email_address).to receive(:user).and_return(double(:user, name: 'Foo Bar'))
      allow(email_address).to receive(:address).and_return('foo@bar.io')
    end

    describe '#formatted_email_address' do
      subject { super().formatted_email_address }
      it { is_expected.to eq 'Foo Bar <foo@bar.io>'}
    end
  end
end
