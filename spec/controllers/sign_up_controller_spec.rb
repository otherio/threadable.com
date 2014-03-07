require 'spec_helper'

describe SignUpController, fixtures: true do

  let(:email_address){ 'bob@yourmyface.net' }
  let(:organization_name){ 'Magic Candy Kitty' }

  when_not_signed_in do

    describe 'POST /sign_up' do

      context 'with invalid params', fixtures: false do
        it 'rendered errors as json' do
          post :sign_up
          expect(response.status).to eq 406
          expect(response.body).to be_blank
          expect(trackings).to be_blank

          post :sign_up, sign_up: {organization_name: '', email_address: ''}
          expect(response.status).to eq 406
          expect(response.body).to eq({"errors"=> {"email_address"=>["can't be blank", "is invalid"], "organization_name"=>["can't be blank"]}}.to_json)
          expect(trackings).to be_blank

          post :sign_up, sign_up: {organization_name: 'foo', email_address: ''}
          expect(response.status).to eq 406
          expect(response.body).to eq({"errors"=> {"email_address"=>["can't be blank", "is invalid"]}}.to_json)
          expect(trackings).to be_blank

          post :sign_up, sign_up: {organization_name: 'foo', email_address: 'bar'}
          expect(response.status).to eq 406
          expect(response.body).to eq({"errors"=> {"email_address"=>["is invalid"]}}.to_json)
          expect(trackings).to be_blank

          post :sign_up, sign_up: {organization_name: '', email_address: 'bar@example.com'}
          expect(response.status).to eq 406
          expect(response.body).to eq({"errors"=> {"organization_name"=>["can't be blank"]}}.to_json)
          expect(trackings).to be_blank
        end
      end

      context "with a valid organization name and new email address", fixtures: false do
        it 'should persist the given email address' do
          post :sign_up, sign_up: { organization_name: organization_name, email_address: email_address }
          expect(response.status).to eq 201
          expect(response.body).to be_blank
          threadable.track('Homepage sign up', email_address: email_address, organization_name: organization_name)
          assert_background_job_enqueued SendEmailWorker, args: [threadable.env, "sign_up_confirmation", organization_name, email_address]
        end
      end

      context "with a valid organization name and an existing user's email address", fixtures: true do
        let(:email_address){ 'alice@ucsd.example.com' }
        let(:organization_name){ 'Magic Candy Kitty' }
        it 'should persist the given email address' do
          post :sign_up, sign_up: { organization_name: organization_name, email_address: email_address }
          expect(response.status).to eq 200
          url = sign_in_path(
            email_address: email_address,
            r: new_organization_path(organization_name: organization_name),
            notice: "You already have an account. Please sign in.",
          )
          expect(response.body).to eq({redirect_to: url}.to_json)
          threadable.track('Homepage sign up', email_address: email_address, organization_name: organization_name)
        end
      end

    end

    describe 'GET /sign_up/confirmation/:token' do
      it 'redirects to post to the same url' do
        get :confirmation, token: 'SOME_FAKE_TOKEN'
        form = Nokogiri.parse(response.body).css('form').first
        expect(form[:action]).to eq sign_up_confirmation_url
      end
    end

    context "and the token contains an existing user's email address", fixtures: true do
      let(:email_address){ 'alice.neilson@gmail.com' }
      let(:alice){ threadable.users.find_by_email_address!('alice@ucsd.example.com') }
      before{ alice.email_addresses.create!(address: email_address) }
      describe 'POST /sign_up/confirmation/:token' do
        let(:token){ SignUpConfirmationToken.encrypt(organization_name, email_address) }
        it 'signs me in as that user, confirms that email address and redirects to the new organization url' do
          post :confirmation, token: token
          expect(response).to redirect_to new_organization_url(token: token)
          expect(controller.current_user).to be_the_same_user_as alice
          expect( threadable.email_addresses.find_by_address(email_address) ).to be_confirmed
        end
      end
    end

    context "and the token contains a new email address", fixtures: false do
      let(:email_address){ 'bob@yourmyface.net' }
      describe 'POST /sign_up/confirmation/:token' do
        let(:token){ SignUpConfirmationToken.encrypt(organization_name, email_address) }
        it 'creates a confirmed email address record and redirects to the new organization url' do
          post :confirmation, token: token
          expect(response).to redirect_to new_organization_url(token: token)
          expect(controller.current_user).to be_nil
          expect( threadable.email_addresses.find_by_address(email_address) ).to be_confirmed
        end
      end
    end

  end

  when_signed_in_as 'yan@ucsd.example.com' do

    context "and the token contains an existing user's email address" do
      let(:email_address){ 'alice.neilson@gmail.com' }
      let(:alice){ threadable.users.find_by_email_address!('alice@ucsd.example.com') }
      before{ alice.email_addresses.create!(address: email_address) }
      describe 'POST /sign_up/confirmation/:token' do
        let(:token){ SignUpConfirmationToken.encrypt(organization_name, email_address) }
        it 'signed me out, signs me in as that user, confirms that email address and redirects to the new organization url' do
          post :confirmation, token: token
          expect(response).to redirect_to new_organization_url(token: token)
          expect(controller.current_user).to be_the_same_user_as alice
          expect( threadable.email_addresses.find_by_address(email_address) ).to be_confirmed
        end
      end
    end

    context "and the token contains a new email address" do
      let(:email_address){ 'bob@yourmyface.net' }
      describe 'POST /sign_up/confirmation/:token' do
        let(:token){ SignUpConfirmationToken.encrypt(organization_name, email_address) }
        it 'signed me out, creates a confirmed email address record and redirects to the new organization url' do
          post :confirmation, token: token
          expect(response).to redirect_to new_organization_url(token: token)
          expect(controller.current_user).to be_nil
          expect( threadable.email_addresses.find_by_address(email_address) ).to be_confirmed
        end
      end
    end

  end

end
