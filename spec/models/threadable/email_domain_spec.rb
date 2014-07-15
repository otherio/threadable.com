require 'spec_helper'

describe Threadable::EmailDomain do

  let :email_domain_record do
    double(:email_domain_record,
      id: 3390,
      domain: 'bar.io',
      outgoing?: true,
    )
  end

  let(:email_domain){ described_class.new(threadable, email_domain_record) }
  subject{ email_domain }

  it { should delegate(:id        ).to(:email_domain_record) }
  it { should delegate(:outgoing? ).to(:email_domain_record) }
  it { should delegate(:errors    ).to(:email_domain_record) }

  its(:threadable         ){ should eq threadable }
  its(:email_domain_record){ should eq email_domain_record }
  its(:inspect            ){ should eq %(#<Threadable::EmailDomain domain: "bar.io", outgoing: true>) }
  its(:to_s               ){ should eq 'bar.io' }

end
