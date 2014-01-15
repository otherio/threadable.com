require 'spec_helper'

describe UsersController do

  when_not_signed_in do

    describe 'GET :index' do
      it 'renders not found' do
        get :index
        expect(response.status).to eq 404
      end
    end

    describe 'POST :create' do
      let :user_params do
        {
          name: "Christopher Hitchens",
          email_address: "christopher@hitchslap.net",
          password: "godisnotgreat",
          password_confirmation: "godisnotgreat",
        }
      end
      let(:user){ double(:user, id: 94, persisted?: persisted) }
      before do
        expect(covered).to receive(:sign_up).with(user_params).and_return(user)
      end
      def post!
        post :create, user: user_params
        expect(response).to be_ok
        expect(assigns[:user]).to eq user
      end
      context 'when the user is successfully created' do
        let(:persisted){ true }
        it 'should redirect to the user created page' do
          expect(covered.emails).to receive(:send_email_async).with(:sign_up_confirmation, 94)
          post!
          expect(response).to render_template :create
        end
      end
      context 'when the user is not successfully created' do
        let(:persisted){ false }
        it 'should render to the user new page' do
          post!
          expect(response).to render_template :new
        end
      end
    end

    describe 'GET :show' do
      it 'redirects to the sign in url with the the current request url as the r param' do
        get :show, id: 'some-user-slug'
        expect(response).to redirect_to sign_in_url(r: user_url('some-user-slug'))
      end
    end

    describe 'GET :edit' do
      it 'redirects to the sign in url with the the current request url as the r param' do
        get :edit, id: 'some-user-slug'
        expect(response).to redirect_to sign_in_url(r: edit_user_url('some-user-slug'))
      end
    end

    describe 'PUT :update' do
      it 'redirects to the sign in url with the the current request url as the r param' do
        put :update, id: 'some-user-slug'
        expect(response).to redirect_to sign_in_url
      end
    end

  end

  when_signed_in_as 'tom@ucsd.example.com' do

    describe 'GET :index' do
      it 'renders not found' do
        get :index
        expect(response.status).to eq 404
      end
    end

    describe 'POST :create' do
      it 'renders unauthorized' do
        post :create, user: {}
        expect(response.status).to eq 401
      end
    end

    describe 'GET :show' do
      it 'should render the user show page' do
        get :show, id: current_user.to_param
        expect(assigns[:user]).to eq current_user
        expect(response).to render_template :show
      end
    end

    describe 'GET :edit' do
      context "when visiting my user edit page" do
        it 'should render the user edit page' do
          get :edit, id: current_user.to_param
          expect(response).to render_template :edit
          expect(assigns[:user]).to eq current_user
        end
      end
      context "when visiting an other user's edit page" do
        it 'renders not found' do
          get :edit, id: 'someone-else'
          expect(response.status).to eq 404
        end
      end
    end

    describe 'PUT :update' do
      context "when updaing me" do
        let :user_params do
          {name: "Tom Canver is awesome"}
        end

        before do
          expect(current_user).to receive(:update).with(user_params).and_return(update_successfull)
          put :update, id: current_user.to_param, user: user_params
          expect(assigns[:user]).to eq current_user
        end
        context 'when the update is successfull' do
          let(:update_successfull){ true }
          it 'should render redirect to the user show page' do
            expect(response).to redirect_to user_url(current_user)
          end
        end
        context 'when the update is not successfull' do
          let(:update_successfull){ false }
          it 'should render the edit page' do
            expect(response).to render_template :edit
          end
        end
      end
      context "when visiting an other user's edit page" do
        it 'renders not found' do
          put :update, id: 'someone-else'
          expect(response.status).to eq 404
        end
      end
    end

  end

end
