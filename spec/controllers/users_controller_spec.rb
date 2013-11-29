require 'spec_helper'

describe UsersController do

  when_not_signed_in do

    describe 'GET :index' do
      it 'should render a 404' do
        get :index
        expect(response).to render_template "errors/error_404"
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

    describe 'GET :new' do
      context 'when signups are enabled' do
        before{ expect(controller).to receive(:signup_enabled?).and_return(true) }
        it 'should render the new user page' do
          new_user = double(:new_user)
          expect(covered.users).to receive(:new).and_return(new_user)
          get :new
          expect(assigns[:user]).to eq new_user
          expect(response).to render_template :new
        end
      end
      context 'when signups are disabled' do
        before{ expect(controller).to receive(:signup_enabled?).and_return(false) }
        it "should render a 404" do
          get :new
          expect(response).to render_template "errors/error_404"
        end
      end
    end

    describe 'GET :show' do
      it 'should render a 404' do
        get :show, id: 'some-user-slug'
        expect(response).to render_template "errors/error_404"
      end
    end

    describe 'GET :edit' do
      it 'should render a 404' do
        get :edit, id: 'some-user-slug'
        expect(response).to render_template "errors/error_404"
      end
    end

    describe 'PUT :update' do
      it 'should render a 404' do
        put :update, id: 'some-user-slug'
        expect(response).to render_template "errors/error_404"
      end
    end

  end

  when_signed_in_as 'tom@ucsd.covered.io' do

    describe 'GET :index' do
      it 'should render a 404' do
        get :index
        expect(response).to render_template "errors/error_404"
      end
    end

    describe 'POST :create' do
      it 'should render a 404' do
        post :create, user: {}
        expect(response).to render_template "errors/error_404"
      end
    end


    describe 'GET :new' do
      it 'should render a 404' do
        get :new
        expect(response).to render_template "errors/error_404"
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
        it 'should render a 404' do
          get :edit, id: 'someone-else'
          expect(response).to render_template "errors/error_404"
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
        it 'should render a 404' do
          put :update, id: 'someone-else'
          expect(response).to render_template "errors/error_404"
        end
      end
    end

  end

end
