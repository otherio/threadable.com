require 'spec_helper'

describe Threadable::User::Organizations do
  let(:user) { threadable.users.find_by_email_address('lilith@sfhealth.example.com') }

  describe '#unconfirmed' do
    it 'fetches the orgs that are not confirmed' do
      expect(user.organizations.unconfirmed.first.slug).to eq 'sfhealth'
      expect(user.organizations.unconfirmed.count).to eq 1
    end
  end

end
