require 'spec_helper'

describe IdentifyThreadableEmailAddress, fixtures: false do

  examples = {
    'Ian Baker <ian@other.io>' => false,
    'ian@other.io'             => false,
    'raceteam@threadable.com'      => true,
    'foo+bar@threadable.com'       => true,
    'foo@staging.threadable.com'   => true,
    'raceteam@127.0.0.1'       => true,
  }

  examples.each do |email_address, expected_result|
    context "when given #{email_address.inspect}" do
      subject{ described_class.call(Mail::Address.new(email_address)) }
      it { should == expected_result }
    end
  end
end
