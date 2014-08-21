require 'spec_helper'

describe Threadable::EmailDomain, :type => :model do

  let :email_domain_record do
    double(:email_domain_record,
      id: 3390,
      domain: 'bar.io',
      outgoing?: true,
    )
  end

  let(:email_domain){ described_class.new(threadable, email_domain_record) }
  subject{ email_domain }

  it { is_expected.to delegate(:id        ).to(:email_domain_record) }
  it { is_expected.to delegate(:outgoing? ).to(:email_domain_record) }
  it { is_expected.to delegate(:errors    ).to(:email_domain_record) }
  it { is_expected.to delegate(:destroy   ).to(:email_domain_record) }

  describe '#threadable' do
    subject { super().threadable }
    it { is_expected.to eq threadable }
  end

  describe '#email_domain_record' do
    subject { super().email_domain_record }
    it { is_expected.to eq email_domain_record }
  end

  describe '#inspect' do
    subject { super().inspect }
    it { is_expected.to eq %(#<Threadable::EmailDomain domain: "bar.io", outgoing: true>) }
  end

  describe '#to_s' do
    subject { super().to_s }
    it { is_expected.to eq 'bar.io' }
  end

end
