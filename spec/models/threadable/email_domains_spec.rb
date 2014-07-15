require 'spec_helper'

describe Threadable::EmailDomains do

  let(:email_domains){ described_class.new(threadable) }
  subject{ email_domains }

  its(:threadable){ should eq threadable }
end
