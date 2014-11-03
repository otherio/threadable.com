require 'spec_helper'

describe EmailAddressesController, :type => :controller do

  when_not_signed_in do

    describe 'POST /email_addresses' do
      it 'should redirect to a sign in page' do
        post :create
        expect(response).to redirect_to sign_in_path
      end
    end

    describe 'PATCH /email_addresses' do
      it 'should redirect to a sign in page' do
        patch :update
        expect(response).to redirect_to sign_in_path
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

    describe 'POST /email_addresses' do
      it 'should add the email address to the current users account' do
        patch :update, email_address: { address: 'yan@yansterdam.io', primary: 1 }
        expect(response).to redirect_to profile_path(expand_section: 'email')
        expect(flash[:error]).to be_nil
        expect(flash[:notice]).to eq "yan@yansterdam.io is now your primary email address."
        expect(current_user.email_addresses.find_by_address!('yan@yansterdam.io')).to be_primary
      end
    end

  end
end
