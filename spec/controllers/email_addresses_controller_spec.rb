require 'spec_helper'

describe EmailAddressesController, :type => :controller do
  let(:organization)  { threadable.organizations.find_by_slug('raceteam') }
  let(:user)          { organization.members.find_by_email_address('yan@ucsd.example.com') }
  let(:email_address) { user.email_addresses.create!(address: 'foo@bar.com') }

  when_not_signed_in do

    describe 'POST /email_addresses' do
      it 'should redirect to a sign in page' do
        post :create
        expect(response).to redirect_to sign_in_path
      end
    end

    describe 'PATCH /email_address' do
      it 'should redirect to a sign in page' do
        patch :update
        expect(response).to redirect_to sign_in_path
      end
    end

    describe 'GET /confirm' do
      it 'confirms the address and redirects to the sign in page' do
        get :confirm, token: EmailAddressConfirmationToken.encrypt(email_address.id)
        email_address.reload
        expect(email_address.confirmed?).to be_truthy
        expect(response).to redirect_to sign_in_path(r: profile_path(expand_section: 'email'))
      end
    end

  end

  when_signed_in_as 'yan@ucsd.example.com' do

    describe 'POST /email_addresses' do
      it 'should add the email address to the current users account' do
        post :create, email_address: { address: 'foo@example.com' }
        expect(response).to redirect_to profile_path(expand_section: 'email')
        expect(flash[:error]).to be_nil
      end
    end

    describe 'PATCH /email_address' do
      it 'should add the email address to the current users account' do
        patch :update, email_address: { address: 'yan@yansterdam.io', primary: 1 }
        expect(response).to redirect_to profile_path(expand_section: 'email')
        expect(flash[:error]).to be_nil
        expect(flash[:notice]).to eq "yan@yansterdam.io is now your primary email address."
        expect(current_user.email_addresses.find_by_address!('yan@yansterdam.io')).to be_primary
      end
    end

    describe 'GET /confirm' do
      it 'confirms the address and redirects to the sign in page' do
        get :confirm, token: EmailAddressConfirmationToken.encrypt(email_address.id)
        email_address.reload
        expect(email_address.confirmed?).to be_truthy
        expect(response).to redirect_to profile_path(expand_section: 'email')
      end
    end

  end
end
