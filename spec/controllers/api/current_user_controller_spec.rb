require 'spec_helper'

describe Api::CurrentUserController do

   when_not_signed_in do

    describe 'show' do
      it 'renders a blank current user as json' do
        xhr :get, :show, format: :json
        expect(response.status).to eq 200
        expect(response.body).to eq serialize(:current_user, current_user).to_json
      end
    end

  end

  when_signed_in_as 'bob@ucsd.example.com' do
    describe 'show' do
      it 'renders bob as json' do
        xhr :get, :show, format: :json
        expect(response.status).to eq 200
        expect(response.body).to eq serialize(:current_user, current_user).to_json
      end
    end
  end

  when_signed_in_as 'alice@ucsd.example.com' do
    describe 'show' do
      it 'renders alice as json' do
        xhr :get, :show, format: :json
        expect(response.status).to eq 200
        expect(response.body).to eq serialize(:current_user, current_user).to_json
      end
    end
  end

end
