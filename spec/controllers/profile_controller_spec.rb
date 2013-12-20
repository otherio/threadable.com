require 'spec_helper'

describe ProfileController do

  when_not_signed_in do

    describe 'GET /profile' do
      it 'should redirect to a sign in page' do
        get :show
        expect(response).to redirect_to sign_in_path(r: profile_url)
      end
    end

    describe 'PATCH /profile' do
      it 'should redirect to a sign in page' do
        patch :update
        expect(response).to redirect_to sign_in_path
      end
    end

  end

  when_signed_in_as 'yan@ucsd.covered.io' do

    describe 'GET /profile' do
      it 'should render the profile show template' do
        get :show
        expect(response).to render_template('profile/show')
      end
    end

    describe 'PATCH /profile' do

      context 'when updating your name' do
        it 'should update your name' do
          patch :update, user: { name: 'Yan!' }
          expect(response).to redirect_to profile_path
          expect(flash[:notice]).to eq "We've updated your profile"
        end
      end

      context 'when updating your password' do
        it 'should update your password' do
          patch :update, user: {
            current_password:      'password',
            password:              'supersecret',
            password_confirmation: 'supersecret',
          }
          expect(response).to redirect_to profile_path
          expect(flash[:notice]).to eq "We've changed your password"
        end

        context 'with bad params' do
          it 'should render the profile page with errors' do
            patch :update, user: {
              current_password:      'passwor',
              password:              'supersecret',
              password_confirmation: 'supersecret',
            }
            expect(response).to render_template('profile/show')
            expect(current_user.errors.to_a).to eq ["Current password wrong password"]
          end
          it 'should render the profile page with errors' do
            patch :update, user: {
              current_password:      'password',
              password:              'supersecret',
              password_confirmation: 'supersecrey',
            }
            expect(response).to render_template('profile/show')
            expect(current_user.errors.to_a).to eq ["Password confirmation doesn't match Password"]
          end
        end
      end

    end

  end

end
