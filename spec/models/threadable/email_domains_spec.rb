require 'spec_helper'

describe Threadable::EmailDomains, :type => :model do

  let(:email_domains){ described_class.new(threadable) }
  subject{ email_domains }

  describe '#threadable' do
    subject { super().threadable }
    it { is_expected.to eq threadable }
  end
end
