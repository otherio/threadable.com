require 'spec_helper'

describe Threadable::EmailDomains, :type => :request do

  let(:email_domains){ described_class.new(threadable) }
  subject{ email_domains }

  describe '#threadable' do
    subject { super().threadable }
    it { is_expected.to eq threadable }
  end

  describe '#find_by_domain' do
    it 'returns the first matching email domain for the given domain' do
      expect(email_domains.find_by_domain('raceteam.com')).to be_a Threadable::EmailDomain
    end
  end

  describe '#taken?' do
    it 'is true for a domain that is in use' do
      expect(email_domains.taken?('raceteam.com')).to be_truthy
      expect(email_domains.taken?('something.io')).to be_falsey
    end
  end

end
