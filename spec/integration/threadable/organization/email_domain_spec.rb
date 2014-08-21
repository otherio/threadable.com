require 'spec_helper'

describe Threadable::Organization::EmailDomain, :type => :request do

  let(:organization_record ){ email_domain_record.organization }
  let(:email_domain_records){ organization_record.email_domains }
  let(:organization        ){ threadable.organizations.find_by_slug('raceteam') }
  let(:email_domain        ){ described_class.new(organization, email_domain_record) }
  subject{ email_domain }

  let(:email_domain_record){ organization.email_domains.all.first.email_domain_record }

  describe '#id' do
    subject { super().id }
    it { is_expected.to eq email_domain_record.id         }
  end

  describe '#domain' do
    subject { super().domain }
    it { is_expected.to eq email_domain_record.domain    }
  end

  describe '#outgoing?' do
    subject { super().outgoing? }
    it { is_expected.to eq email_domain_record.outgoing?   }
  end

  describe '#errors' do
    subject { super().errors }
    it { is_expected.to eq email_domain_record.errors     }
  end

  describe '#persisted?' do
    subject { super().persisted? }
    it { is_expected.to eq email_domain_record.persisted? }
  end

  describe '#to_s' do
    subject { super().to_s }
    it { is_expected.to eq email_domain.domain           }
  end

  describe '#outgoing!' do
    context 'when signed in as an owner' do
      before do
        sign_in_as 'alice@ucsd.example.com'
      end

      context 'with a paid organization' do
        it 'returns true and enables outgoing, while disabling outgoing for other domains' do
          organization.email_domains.add('foo.com', true)
          expect(organization.email_domains.find_by_domain('foo.com')).to be_outgoing

          expect(email_domain_record).to_not be_outgoing
          expect(email_domain.outgoing!).to be_truthy
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

    context 'when signed in as a user' do
      before do
        sign_in_as 'bob@ucsd.example.com'
      end

      it 'raises an exception' do
        expect { email_domain.outgoing! }.to raise_error Threadable::AuthorizationError, 'You do not have permission to change settings for this organization'
      end
    end
  end

  describe '#not_outgoing!' do
    context 'when signed in as an owner' do
      before do
        sign_in_as 'alice@ucsd.example.com'
      end

      context 'with a paid organization' do
        it 'returns true and disables outgoing' do
          email_domain.outgoing!
          expect(email_domain_record).to be_outgoing
          expect(email_domain.not_outgoing!).to be_truthy
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

    context 'when signed in as a user' do
      before do
        sign_in_as 'bob@ucsd.example.com'
      end

      it 'raises an exception' do
        expect { email_domain.not_outgoing! }.to raise_error Threadable::AuthorizationError, 'You do not have permission to change settings for this organization'
      end
    end
  end
end
