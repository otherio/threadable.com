require 'spec_helper'

describe AdminController do

  when_not_signed_in do

    describe 'GET :show' do
      it 'should render a 404' do
        get :show
        expect(response).to redirect_to sign_in_url(r: admin_url)
      end
    end

  end

  when_signed_in_as 'ian@other.io' do
    describe 'GET :show' do
      it 'should render the admin show page' do
        get :show
        expect(response).to render_template :show
      end
    end
  end

end
