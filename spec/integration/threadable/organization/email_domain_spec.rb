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
    context 'with a paid organization' do
      it 'returns true and enables outgoing, while disabling outgoing for other domains' do
        organization.email_domains.add('foo.com', true)
        expect(organization.email_domains.find_by_domain('foo.com')).to be_outgoing

        expect(email_domain_record).to_not be_outgoing
        expect(email_domain.outgoing!).to be_true
        expect(email_domain_record.reload).to be_outgoing
        expect(organization.email_domains.find_by_domain('foo.com')).to_not be_outgoing
      end
    end

    context 'with a free organization' do
      before do
        organization.update(plan: :free)
      end

      it 'raises an error' do
        expect { email_domain.outgoing! }.to raise_error Threadable::AuthorizationError, "A paid account is required to change domain settings"
      end
    end
  end

  describe '#not_outgoing!' do
    context 'with a paid organization' do
      it 'returns true and disables outgoing' do
        email_domain.outgoing!
        expect(email_domain_record).to be_outgoing
        expect(email_domain.not_outgoing!).to be_true
        expect(email_domain_record.reload).to_not be_outgoing
      end
    end

    context 'with a free organization' do
      before do
        organization.update(plan: :free)
      end

      it 'raises an error' do
        expect { email_domain.not_outgoing! }.to raise_error Threadable::AuthorizationError, "A paid account is required to change domain settings"
      end
    end
  end
end
