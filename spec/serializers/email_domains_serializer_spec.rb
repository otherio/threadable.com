require 'spec_helper'

describe EmailDomainsSerializer do

  let(:raceteam) { threadable.organizations.find_by_slug!('raceteam') }
  let(:domains) { raceteam.email_domains.all }
  let(:domain1) { domains.first }
  let(:domain2) { domains.last }

  before{ sign_in_as 'alice@ucsd.example.com' }

  context 'when given a single record' do
    let(:payload){ domain1 }
    let(:expected_key){ :email_domain }
    it do
      should eq(
        id:                domain1.id,
        organization_slug: domain1.organization.slug,
        domain:            domain1.domain,
        outgoing:          false,
      )
    end
  end

  context 'when given a collection of records' do
    let(:payload){ [domain1, domain2] }
    let(:expected_key){ :email_domains }
    it do
      should eq [
        {
          id:                domain1.id,
          organization_slug: domain1.organization.slug,
          domain:            domain1.domain,
          outgoing:          false,
        },{
          id:                domain2.id,
          organization_slug: domain2.organization.slug,
          domain:            domain2.domain,
          outgoing:          false,
        },
      ]
    end
  end

end
