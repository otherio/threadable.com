require 'spec_helper'

describe Threadable::Organization::EmailDomains do

  let(:organization) { threadable.organizations.find_by_slug('raceteam') }
  let(:email_domains){ organization.email_domains }
  subject{ email_domains }

  its(:threadable){ should eq threadable }

  describe '#outgoing' do
    before do
      sign_in_as 'alice@ucsd.example.com'
    end

    it 'returns the outgoing domain, if present' do
      expect(email_domains.outgoing).to be_nil
      email_domains.all.first.outgoing!
      expect(email_domains.outgoing).to be_a Threadable::Organization::EmailDomain
    end
  end

  describe '#add' do
    context 'when signed in as an owner' do
      before do
        sign_in_as 'alice@ucsd.example.com'
      end

      context 'with a paid organization' do
        it 'adds the domain' do
          email_domains.add('foo.com')
          expect(email_domains.all.length).to eq 3
        end
      end

      context 'with a free organization' do
        before do
          organization.update(plan: :free)
        end

        it 'raises an error' do
          expect { email_domains.add('foo.com') }.to raise_error Threadable::AuthorizationError, "A paid account is required to change domain settings"
        end
      end
    end

    context 'when signed in as a user' do
      before do
        sign_in_as 'bob@ucsd.example.com'
      end

      it 'raises an exception' do
        expect { email_domains.add('foo.com') }.to raise_error Threadable::AuthorizationError, 'You do not have permission to change settings for this organization'
      end
    end
  end

  describe '#remove' do
    context 'when signed in as an owner' do
      before do
        sign_in_as 'alice@ucsd.example.com'
      end

      it 'removes the domain' do
        email_domains.remove('raceteam.com')
        expect(email_domains.all.length).to eq 1
      end
    end

    context 'when signed in as a user' do
      before do
        sign_in_as 'bob@ucsd.example.com'
      end

      it 'raises an exception' do
        expect { email_domains.remove('raceteam.com') }.to raise_error Threadable::AuthorizationError, 'You do not have permission to change settings for this organization'
      end
    end
  end

end
