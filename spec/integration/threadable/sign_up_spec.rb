require 'spec_helper'

describe Threadable::SignUp, fixtures: false do

  let :attributes do
    {
      name:                  'Thomas Shaffer',
      email_address:         'thomas@shaffer.me',
      password:              'password',
      password_confirmation: 'password',
    }
  end

  let(:user){ described_class.call(threadable, attributes) }

  it 'creates a user' do
    expect(user).to be_persisted
    expect(user).to be_valid
  end

  def self.escape_unicode string
    string.bytes.to_a.map(&:chr).join.inspect
  end

  valid_email_addresses = [
    %(jared@cover.io),
    %(jared+threadable@cover.io),
    %(jared@127.0.0.1),
    %(\xEF\xBB\xBFjared@deadlyicon.com), # FYI this string contains a zero-width no-break space (U+FEFF)
    %(jared+\xE2\x98\x83@deadlyicon.com),
  ]

  invalid_email_addresses = [
    %(jared@localhost),
    %(jared),
    %(ian.baker@foo),
  ]

  valid_email_addresses.each do |email_address|
    context "when given the email_address #{escape_unicode(email_address)}" do
      it 'returns a persisted user' do
        attributes[:email_address] = email_address
        expect(user).to be_persisted
        expect(user.email_address).to eq email_address.strip_non_ascii
      end
    end
  end

  invalid_email_addresses.each do |email_address|
    context "when given the email_address #{escape_unicode(email_address)}" do
      it 'returns a non-persisted user' do
        attributes[:email_address] = email_address
        expect(user).to_not be_persisted
        expect(user.errors['email_addresses.address']).to eq ['is invalid']
      end
    end
  end

end
