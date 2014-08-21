require 'spec_helper'

describe Threadable::User::Organization, :type => :request do
  let(:user) { threadable.users.find_by_email_address('lilith@sfhealth.example.com') }
  let(:organization) { user.organizations.find_by_slug('sfhealth') }

  describe '#confirm!' do
    it 'confirms the organization membership' do
      expect(user.organizations.unconfirmed.first.slug).to eq 'sfhealth'
      organization.confirm!
      expect(user.organizations.unconfirmed.count).to eq 0
    end
  end

end
