require 'spec_helper'

describe "signup", fixtures: false do

  let(:name)                  { 'Jeffrey Wescot' }
  let(:email_address)         { %(jeffrey@wescott.me) }
  let(:password)              { 'password' }
  let(:password_confirmation) { 'password' }

  let :params do
    {
      user: {
        name:                  name,
        email_address:         email_address,
        password:              password,
        password_confirmation: password_confirmation,
      }
    }
  end

  context 'with valid params' do
    it "should be successful" do
      expect{ post '/users', params }.to change{ User.count }.by(1)
      expect(response).to be_success
      user = User.last
      expect(user.name         ).to eq 'Jeffrey Wescot'
      expect(user.email_address).to eq %(jeffrey@wescott.me)
    end
  end

  context 'with an email address containing non-ascii characters' do
    let(:email_address){ %(\xEF\xBB\xBFjeffrey@wescott.me) }
    it "should be successful" do
      expect{ post '/users', params }.to change{ User.count }.by(1)
      expect(response).to be_success
      user = User.last
      expect(user.name         ).to eq 'Jeffrey Wescot'
      expect(user.email_address).to eq %(jeffrey@wescott.me)
    end
  end

end
