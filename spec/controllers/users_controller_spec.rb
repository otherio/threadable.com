require 'spec_helper'

describe UsersController do

  context 'when not signed in' do
    before { sign_out! }

    describe 'GET index' do
      it "should redirect to the sign in page" do
        get :index
        expect(response).to redirect_to sign_in_path(r:request.url)
      end
    end

    describe 'POST create' do

      def valid_params
        {
          user: {
            name:                  'Bob Saget',
            email_address:         'bob@sagetyourself.io',
            password:              'password',
            password_confirmation: 'password',
          }
        }
      end

      before do
        expect(covered).to receive(:sign_up).with(valid_params[:user]).and_return(fake_user)
      end

      context 'when the users is created successfully' do
        let(:fake_user){ double(:user, id: 456, email_address: 'a@a.io', errors: []) }
        it "should redirect to home page" do
          expect(covered.emails).to receive(:send_email_async).with(:sign_up_confirmation, fake_user.id)
          post :create, valid_params
          expect(response).to render_template(:create)
        end
      end

      context 'when the users is created successfully' do
        let(:fake_user){ double(:user, errors: [1]) }
        it "should redirect to home page" do
          post :create, valid_params
          expect(response).to render_template(:new)
        end
      end
    end

    describe 'GET new' do
      context 'when signups are enabled' do
        before{ expect(controller).to receive(:signup_enabled?).and_return(true) }
        it "should create a new user and render the new template" do
          get :new
          expect(assigns[:user].id           ).to be_nil
          expect(assigns[:user].email_address).to be_nil
          expect(assigns[:user].slug         ).to be_nil
          expect(response).to render_template(:new)
        end
      end
      context 'when signups are disabled' do
        before{ expect(controller).to receive(:signup_enabled?).and_return(false) }
        it "should create a new user and render the new template" do
          get :new
          expect(response).to redirect_to root_path
        end
      end
    end

    describe 'GET show' do
      it "should redirect to the sign in page" do
        get :show, id: 'irrelevant'
        expect(response).to redirect_to sign_in_path(r:request.url)
      end
    end

    describe 'GET edit' do
      it "should redirect to the sign in page" do
        get :edit, id: 'irrelevant'
        expect(response).to redirect_to sign_in_path(r:request.url)
      end
    end

    describe 'PUT update' do
      it "should redirect to the sign in page" do
        get :update, id: 'irrelevant'
        expect(response).to redirect_to sign_in_path(r:request.url)
      end
    end

  end


  context 'when signed in' do
    before { sign_in! find_user_by_slug("alice-neilson") }
    let(:john){ find_user_by_slug 'bob-cauchois' }

    describe 'GET index' do
      it "should redirect to the sign in page" do
        get :index
        expect(response).to redirect_to root_path
      end
    end

    describe 'POST create' do
      it "should redirect to home page" do
        get :index
        expect(response).to redirect_to root_path
      end
    end

    describe 'GET new' do
      it "should create a new user and render the new template" do
        get :new
        expect(response).to redirect_to root_path
      end
    end

    describe 'GET show' do

      it "should redirect to the sign in page" do
        get :show, id: john.slug
        expect(assigns[:user].id).to eq john.id
        expect(response).to render_template :show
      end
    end

    describe 'GET edit' do
      context 'when editing someone else' do
        it "should redirect me to the home page" do
          get :edit, id: john.slug
          expect(assigns[:user].id).to eq john.id
          expect(response).to redirect_to root_path
        end
      end
      context 'when editing myself' do
        it "should render the edit template" do
          get :edit, id: current_user.slug
          expect(assigns[:user].id).to eq current_user.id
          expect(response).to render_template :edit
        end
      end
    end

    describe 'PUT update' do

      def user_params
        {
          name:                  'Bob Saget',
          email_address:         'bob@sagetyourself.io',
          password:              'password',
          password_confirmation: 'password',
        }
      end

      context 'when updating someone else' do

        it "should redirect me to the home page" do
          get :update, id: john.slug, user: user_params
          expect(assigns[:user].id).to eq john.id
          expect(response).to redirect_to root_path
        end

      end

      context 'when updating myself' do

        context 'and the update is successfull' do
          before do
            expect(current_user).to receive(:update!).with(user_params).and_return(true)
          end

          it "should render the edit template" do
            put :update, id: current_user.slug, user: user_params
            expect(assigns[:user].id).to eq current_user.id
            expect(response).to redirect_to root_path
          end
        end

        context 'and the update fails' do
          before do
            expect(current_user).to receive(:update!).with(user_params).and_return(false)
          end

          it "should render the edit template" do
            put :update, id: current_user.slug, user: user_params
            expect(assigns[:user].id).to eq current_user.id
            expect(response).to render_template :edit
          end
        end

      end
    end

  end


end
