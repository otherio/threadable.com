require 'spec_helper'

describe SignUpController do

  when_not_signed_in do

    describe 'GET /sign_up' do
      it 'should render the sign up form' do
        get :show
        expect(response).to render_template :show
        assert_tracked(nil, 'Sign up page visited')
      end
    end

    describe 'POST /sign_up' do
      context 'with a new email address' do
        let(:email_address){ 'bob@yourmyface.net' }
        let(:organization_name){ 'Magic Candy Kitty' }
        it 'should persist the given email address' do
          expect{
            post :sign_up, sign_up: { organization_name: organization_name, email_address: email_address }
          }.to change{ EmailAddress.count }.by(1)
          expect(EmailAddress.last.address).to eq email_address
          expect(response).to render_template :thank_you
          assert_background_job_enqueued SendEmailWorker, args: [threadable.env, "sign_up_confirmation", organization_name, email_address]
          assert_tracked nil, 'Signed up', organization_name: organization_name, email_address: email_address, result: 'rendered thank you and sent email'
        end
      end
      context 'with an existing email address' do
        let(:email_address){ 'alice@ucsd.example.com' }
        let(:organization_name){ 'Magic Candy Kitty' }
        it 'should persist the given email address' do
          expect{
            post :sign_up, sign_up: { organization_name: organization_name, email_address: email_address }
          }.to_not change{ EmailAddress.count }
          expect(response).to redirect_to sign_in_path(
            email_address: email_address,
            r: new_organization_path(organization_name: organization_name),
            notice: "You already have an account. Please sign in.",
          )
          assert_tracked nil, 'Signed up', organization_name: organization_name, email_address: email_address, result: 'redirected to sign in page'
        end
      end
    end

  end

  when_signed_in_as 'yan@ucsd.example.com' do
    describe 'GET /sign_up' do
      it 'should redirect to /' do
        get :show
        expect(response).to redirect_to root_path
        expect(trackings).to be_empty
      end
    end
    describe 'POST /sign_up' do
      it 'should redirect to /' do
        post :sign_up
        expect(response).to redirect_to root_path
        expect(trackings).to be_empty
      end
    end
  end

end
