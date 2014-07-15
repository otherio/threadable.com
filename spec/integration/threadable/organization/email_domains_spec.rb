require 'spec_helper'

describe Threadable::Organization::EmailDomains do

  let(:organization) { threadable.organizations.find_by_slug('raceteam') }
  let(:email_domains){ organization.email_domains }
  subject{ email_domains }

  its(:threadable){ should eq threadable }

  describe '#outgoing' do
    it 'returns the outgoing domain, if present' do
      expect(email_domains.outgoing).to be_nil
      email_domains.all.first.outgoing!
      expect(email_domains.outgoing).to be_a Threadable::Organization::EmailDomain
    end
  end

  describe '#add' do
    it 'adds the domain' do
      email_domains.add('foo.com')
      expect(email_domains.all.length).to eq 3
    end
  end

end
