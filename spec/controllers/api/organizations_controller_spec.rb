require 'spec_helper'

describe Api::OrganizationsController do

  when_not_signed_in do
    describe 'index' do
      it 'renders unauthorized' do
        xhr :get, :index, format: :json
        expect(response.status).to eq 401
      end
    end
    describe 'create' do
      it 'renders unauthorized' do
        xhr :post, :create, format: :json
        expect(response.status).to eq 401
      end
    end
    describe 'show' do
      it 'renders unauthorized' do
        xhr :get, :show, format: :json, id: 1
        expect(response.status).to eq 401
      end
    end
    describe 'update' do
      it 'renders unauthorized' do
        xhr :patch, :update, format: :json, id: 1
        expect(response.status).to eq 401
      end
    end
    describe 'destroy' do
      it 'renders unauthorized' do
        xhr :delete, :destroy, format: :json, id: 1
        expect(response.status).to eq 401
      end
    end
  end

  when_signed_in_as 'bob@ucsd.example.com' do

    let(:raceteam){ current_user.organizations.find_by_slug! 'raceteam' }
    let(:sfhealth){ current_user.organizations.find_by_slug! 'sfhealth' }

    # get /api/organizations
    describe 'index' do
      it "should render the current users's organizations as json" do
        xhr :get, :index, format: :json
        expect(response).to be_ok
        expect(response.body).to eq serialize(:organizations, [raceteam]).to_json
      end
    end

    # post /api/organizations
    describe 'create' do

    end

    # get /api/organizations/:id
    describe 'show' do
      context 'when given a valid organization id' do
        it "should render the current users's organizations as json" do
          xhr :get, :show, format: :json, id: raceteam.slug
          expect(response).to be_ok
          expect(response.body).to eq serialize(:organizations, raceteam).to_json
        end
      end
      context 'when given an invalid organization id' do
        it "should render the current users's organizations as json" do
          xhr :get, :show, format: :json, id: 32843874832
          expect(response.status).to eq 404
        end
      end
    end

    # patch /api/organizations/:id
    describe 'update' do

    end

    # delete /api/organizations/:id
    describe 'destroy' do

    end

  end


end
