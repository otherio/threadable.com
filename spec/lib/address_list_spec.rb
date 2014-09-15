require 'spec_helper'

describe AddressList, fixtures: false do
  examples = {
    ['Ian Baker <ian@other.io>'             ] => ['ian@other.io'],
    ['ian@other.io'                         ] => ['ian@other.io'],
    ['ian.baker@other.io'                   ] => ['ian.baker@other.io'],
    ['ian.baker@other.io', 'jared@other.io' ] => ['ian.baker@other.io', 'jared@other.io'],
    [nil, 'ian.baker@other.io', ''          ] => ['ian.baker@other.io'],
    ['Ravi S. Rāmphal <ravi@apportable.com>'] => ['ravi@apportable.com'],
    ['Ravi S. Rāmphal: The Deliverator <ravi@apportable.com>'] => ['ravi@apportable.com'],
    ['Ravi S. Rāmphal, Sr. <ravi@apportable.com>'] => ['ravi@apportable.com'],
    ['Ravi S. Rāmphal, Sr. <ravi@apportable.com>, foo@bar.com, bar@bar.com, "The Thing" <thing@thing.com>'] => ['ravi@apportable.com', 'foo@bar.com', 'bar@bar.com', 'thing@thing.com'],
  }

  examples.each do |email_addresses, expected_result|
    context "when given #{email_addresses.inspect}" do
      subject{ described_class.call(email_addresses).map(&:address) }
      it { is_expected.to eq(expected_result) }
    end
  end

end
