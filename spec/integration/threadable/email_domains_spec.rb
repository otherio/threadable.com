require 'spec_helper'

describe Threadable::EmailDomains do

  let(:email_domains){ described_class.new(threadable) }
  subject{ email_domains }

  its(:threadable){ should eq threadable }

  describe '#find_by_domain' do
    it 'returns the first matching email domain for the given domain' do
      expect(email_domains.find_by_domain('raceteam.com')).to be_a Threadable::EmailDomain
    end
  end

  describe '#taken?' do
    it 'is true for a domain that is in use' do
      expect(email_domains.taken?('raceteam.com')).to be_true
      expect(email_domains.taken?('something.io')).to be_false
    end
  end

end
