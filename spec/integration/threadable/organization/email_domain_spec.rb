require 'spec_helper'

describe Threadable::Organization::EmailDomain do

  let(:organization_record ){ email_domain_record.organization }
  let(:email_domain_records){ organization_record.email_domains }
  let(:organization        ){ threadable.organizations.find_by_slug('raceteam') }
  let(:email_domain        ){ described_class.new(organization, email_domain_record) }
  subject{ email_domain }

  let(:email_domain_record){ organization.email_domains.all.first.email_domain_record }

  its(:id        ){ should eq email_domain_record.id         }
  its(:domain    ){ should eq email_domain_record.domain    }
  its(:outgoing? ){ should eq email_domain_record.outgoing?   }
  its(:errors    ){ should eq email_domain_record.errors     }
  its(:persisted?){ should eq email_domain_record.persisted? }
  its(:to_s      ){ should eq email_domain.domain           }

  describe '#outgoing!' do
    context 'when the email domain is not outgoing but confirmed' do
      it 'returns true' do
        expect(email_domain_record).to_not be_outgoing
        expect(email_domain.outgoing!).to be_true
      end
    end
  end
end
