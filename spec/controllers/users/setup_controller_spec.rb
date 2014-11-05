require 'spec_helper'

describe Users::SetupController, :type => :controller do
  include EmberRouteUrlHelpers


  when_not_signed_in do

    describe 'GET /setup' do
      let(:sfhealth) { threadable.organizations.find_by_slug('sfhealth') }
      let(:bones) { sfhealth.members.find_by_email_address('bones@sfhealth.example.com') }
      let(:marcus) { sfhealth.members.find_by_email_address('marcus@sfhealth.example.com') }

      it 'should render the account setup form, and confirm the user' do
        get :edit, token: UserSetupToken.encrypt(bones.id, organization_path(sfhealth))
        expect(response).to render_template :edit
        expect(bones.reload).to be_confirmed
      end

      context 'when the user is web enabled' do
        it 'confirms the user and redirects' do
          get :edit, token: UserSetupToken.encrypt(marcus.id, organization_path(sfhealth))
          expect(response).to redirect_to(sign_in_path(r: organization_path(sfhealth)))
          expect(marcus.reload).to be_confirmed
        end
      end

      context 'when the token contains an organization id' do
        it 'should render the account setup form, and confirm the user' do
          get :edit, token: UserSetupToken.encrypt(bones.id, sfhealth.id)
          expect(response).to render_template :edit
          expect(bones.reload).to be_confirmed
        end
      end
    end
  end

  when_signed_in_as 'amywong.phd@gmail.com' do
    describe 'GET /setup' do
      let(:sfhealth) { threadable.organizations.find_by_slug('sfhealth') }
      let(:amy) { sfhealth.members.find_by_email_address('amywong.phd@gmail.com') }
      let(:marcus) { sfhealth.members.find_by_email_address('marcus@sfhealth.example.com') }

      it 'should redirect to the organization path' do
        get :edit, token: UserSetupToken.encrypt(amy.id, organization_path(sfhealth))
        expect(response).to redirect_to organization_path(sfhealth)
        expect(amy.reload).to be_confirmed
      end

      context 'when the user is web enabled' do
        it 'confirms the user and redirects' do
          get :edit, token: UserSetupToken.encrypt(amy.id, organization_path(sfhealth))
          expect(response).to redirect_to(organization_path(sfhealth))
          expect(amy.reload).to be_confirmed
        end
      end

      context 'when the token contains an organization id' do
        it 'should redirect to the organization path' do
          get :edit, token: UserSetupToken.encrypt(amy.id, sfhealth.id)
          expect(response).to redirect_to organization_path(sfhealth)
          expect(amy.reload).to be_confirmed
        end
      end

      context 'when the user is web enabled, but it is not the signed in user' do
        it 'confirms the user and redirects' do
          get :edit, token: UserSetupToken.encrypt(marcus.id, organization_path(sfhealth))
          expect(response).to redirect_to(sign_in_path(r: organization_path(sfhealth)))
          expect(marcus.reload).to be_confirmed
        end
      end

    end
  end

  # when_signed_in_as 'yan@ucsd.example.com' do
  #   describe 'GET /sign_up' do
  #     it 'should redirect to /' do
  #       get :show
  #       expect(response).to redirect_to root_path
  #       expect(trackings).to be_empty
  #     end
  #   end
  #   describe 'POST /sign_up' do
  #     it 'should redirect to /' do
  #       post :sign_up
  #       expect(response).to redirect_to root_path
  #       expect(trackings).to be_empty
  #     end
  #   end
  # end

end
