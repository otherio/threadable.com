require 'spec_helper'

describe ExtractNamesFromEmailAddresses, fixtures: false do

  examples = {
    ['Ian Baker <ian@other.io>'            ] => ['Ian'],
    ['ian@other.io'                        ] => ['ian'],
    ['ian.baker@other.io'                  ] => ['ian'],
    ['ian.baker@other.io', 'jared@other.io'] => ['ian', 'jared'],
    [nil, 'ian.baker@other.io', ''         ] => ['ian'],
  }

  examples.each do |email_addresses, expected_result|
    context "when given #{email_addresses.inspect}" do
      subject{ described_class.call(email_addresses) }
      it { should == expected_result }
    end
  end
end
