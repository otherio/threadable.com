# Encoding: UTF-8

require 'spec_helper'

describe ValidateEmailAddress do

  valid = [
    'jared@other.io',
    'jared+@other.io',
    'jared++++@other.io',
    'jared+money@other.io',
    'jared+money+sex@other.io',
    'jared+money+sex@a.b.c.d.e.f.g.h.i.j.other.io',
  ]

  invalid = [
    '',
    'a',
    'jared plus money@other.io',
    'jared@localhost',
    'jared@.com',
    '@other.io',
    'heh℥@foo.com',
    'jared+♺@other.io',
    'jared@♺.com', # this needs to be valid at some point but Mail::Message cannot parse these domain
    %(\xEF\xBB\xBFjared@deadlyicon.com), # FYI this string contains a zero-width no-break space (U+FEFF)
    %(jared+\xE2\x98\x83@deadlyicon.com),
  ]

  valid.each do |email_address|
    it "valid email: #{email_address.inspect}" do
      expect( described_class.call(email_address) ).to be_true
    end
  end

  invalid.each do |email_address|
    it "invalid email: #{email_address.inspect}" do
      expect( described_class.call(email_address) ).to be_false
    end
  end

end
