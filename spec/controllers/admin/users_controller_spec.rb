require 'spec_helper'

describe Admin::UsersController do

  when_not_signed_in do

    describe 'GET :index' do
      it 'should redirect to the sign in page' do
        get :index
        expect(response).to redirect_to sign_in_url(r: admin_users_url)
      end
    end

    describe 'GET :show' do
      it 'should redirect to the sign in page' do
        get :show, user_id: 'ian-baker'
        expect(response).to redirect_to sign_in_url(r: admin_user_url('ian-baker'))
      end
    end

    describe 'GET :edit' do
      it 'should redirect to the sign in page' do
        get :edit, user_id: 'ian-baker'
        expect(response).to redirect_to sign_in_url(r: admin_edit_user_url('ian-baker'))
      end
    end

    describe 'PUT :update' do
      it 'should redirect to the sign in page' do
        put :update, user_id: 'mary-frank'
        expect(response).to redirect_to sign_in_url
      end
    end

    describe 'POST :merge' do
      it 'should redirect to the sign in page' do
        post :merge, user_id: 'mary-frank', destination_user_id: 123
        expect(response).to redirect_to sign_in_url
      end
    end

  end

  when_signed_in_as 'ian@other.io' do

    describe 'GET :index' do
      it 'render the first 20 users based on an empty search' do
        users = double(:users)
        expect(threadable.users).to receive(:search).with('', page: 0).and_return(users)
        get :index
        expect( assigns[:page]  ).to eq 0
        expect( assigns[:query] ).to eq ""
        expect( assigns[:users] ).to eq users
        expect(response).to render_template :index
      end
    end

    describe 'GET :show' do
      it 'should redirect to the edit action' do
        get :show, user_id: 'ian-baker'
        expect(response).to redirect_to admin_edit_user_url('ian-baker')
      end
    end

    describe 'GET :edit' do
      it 'render admin user edit' do
        user = double(:user)
        expect(threadable.users).to receive(:find_by_slug!).with('ian-baker').and_return(user)
        get :edit, user_id: 'ian-baker'
        expect( assigns[:user] ).to eq user
        expect(response).to render_template :edit
      end
    end

    describe 'PUT :update' do
      let(:user){ double(:user, formatted_email_address: 'Bob Sagat <bob@sagat.me>') }
      def attributes
        {
          'name'                  => 'Jaréd Grîppë',
          'slug'                  => 'jared-influenza',
          'password'              => 'poopdragon',
          'password_confirmation' => 'poopdragon',
          'munge_reply_to'        => '0',
        }
      end

      before do
        expect(threadable.users).to receive(:find_by_slug!).with('jared-grippe').and_return(user)
        expect(user).to receive(:update).with(attributes).and_return(update_result)
      end
      context 'when the update is successful' do
        let(:update_result){ true }
        it 'should redirect to the sign in page' do
          put(:update, user_id: 'jared-grippe', user: attributes)
          expect( assigns[:user] ).to be user
          expect( assigns[:user_params] ).to eq attributes
          expect( flash[:success] ).to eq "update of Bob Sagat <bob@sagat.me> was successful."
          expect(response).to redirect_to admin_users_path
        end
      end
      context 'when the update fails' do
        let(:update_result){ false }
        it 'should redirect to the sign in page' do
          put(:update, user_id: 'jared-grippe', user: attributes)
          expect( assigns[:user] ).to be user
          expect( assigns[:user_params] ).to eq attributes
          expect( flash[:danger] ).to eq "update of Bob Sagat <bob@sagat.me> was unsuccessful."
          expect(response).to render_template :edit
        end
      end
    end

    describe 'POST :merge' do
      let(:user)            { double(:user,             id: 42, name: 'Andy Kaufman', to_param: 'andy-kaufman') }
      let(:destination_user){ double(:destination_user, id: 89, name: 'Tony Clifton', to_param: 'tony-clifton') }

      before do
        expect( threadable.users ).to receive(:find_by_slug!).with('jared-grippe').and_return(user)
        expect( threadable.users ).to receive(:find_by_id!).with('89').and_return(destination_user)
        expect( user             ).to receive(:same_user?).with(current_user).and_return(false)
      end

      context 'when params[:confirmed] is not present' do
        it 'looks up the users and renderes :merge' do
          expect(user).to_not receive(:merge_into!)
          post :merge, user_id: 'jared-grippe', destination_user_id: 89
          expect( assigns[:user]             ).to be user
          expect( assigns[:destination_user] ).to be destination_user
          expect(response).to render_template :merge
        end
      end
      context 'when params[:confirmed] is present' do
        it 'merges the users and redirects to the admin user page for the destination user' do
          expect(user).to receive(:merge_into!).with(destination_user)
          post :merge, user_id: 'jared-grippe', destination_user_id: 89, confirmed: '1'
          expect( assigns[:user]             ).to be user
          expect( assigns[:destination_user] ).to be destination_user
          expect( flash[:success] ).to eq "Andy Kaufman (user 42) was merge into Tony Clifton (user 89)"
          expect(response).to redirect_to admin_user_path(destination_user)
        end
      end
    end

  end

end
