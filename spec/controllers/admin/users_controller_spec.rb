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



    # let(:user){
    #   double :user,
    #   name: 'Mary Frank',
    #   email_address: 'mary@frank.ly',
    #   formatted_email_address: 'Mary Frank <mary@frank.ly>',
    #   id: 898
    # }
    # let(:organization){ double :organization, name: 'Fish Eating Contest', to_param: 'fish-eating-contest'}
    # before do
    #   expect(threadable.users).to receive(:find_by_id!).with(898).and_return(user)
    # end

    # describe 'PUT :update' do
    #   before do
    #     expect(user).to receive(:update).with(munge_reply_to: true).and_return(update_successful)
    #     put :update, user_id: 898, user: {munge_reply_to: true, organization: 'fish-eating-contest'}
    #     expect(response).to redirect_to admin_edit_organization_url(organization)
    #   end
    #   context 'when the update is successfull' do
    #     let(:update_successful){ true }
    #     it 'should redirect to the admin edit organization page' do
    #       expect(flash[:notice]).to eq "update of Mary Frank <mary@frank.ly> was successful."
    #     end
    #   end
    #   context 'when the update is unsuccessfull' do
    #     let(:update_successful){ false }
    #     it 'should redirect to the admin edit organization page' do
    #       expect(flash[:alert]).to eq "update of Mary Frank <mary@frank.ly> was unsuccessful."
    #     end
    #   end

    # end

  end

end
