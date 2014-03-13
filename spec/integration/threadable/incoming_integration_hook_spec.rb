require 'spec_helper'

describe Threadable::IncomingIntegrationHook do

  let(:raceteam      ){ threadable.organizations.find_by_slug!('raceteam') }
  let(:alice         ){ raceteam.members.find_by_email_address!('alice@ucsd.example.com') }
  # let(:incoming_email){ threadable.incoming_emails.create!(params).first }
  # subject{ incoming_email }

  describe 'process!' do
    it 'calls the correct processor class'
  end
end
