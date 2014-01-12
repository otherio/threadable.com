require 'spec_helper'

describe Api::GroupsController do

  when_not_signed_in do
    describe 'index' do
      it 'renders unauthorized' do
        xhr :get, :index, format: :json, organization_id: 1
        expect(response.status).to eq 401
        expect(response.body).to be_blank
      end
    end
    describe 'create' do
      it 'renders unauthorized' do
        xhr :post, :create, format: :json, organization_id: 1
        expect(response.status).to eq 401
        expect(response.body).to be_blank
      end
    end
    describe 'show' do
      it 'renders unauthorized' do
        xhr :get, :show, format: :json, organization_id: 1, group_id: 1, id: 1
        expect(response.status).to eq 401
        expect(response.body).to be_blank
      end
    end
    describe 'update' do
      it 'renders unauthorized' do
        xhr :patch, :update, format: :json, organization_id: 1, group_id: 1, id: 1
        expect(response.status).to eq 401
        expect(response.body).to be_blank
      end
    end
  end

  when_signed_in_as 'bob@ucsd.example.com' do

    let(:raceteam){ covered.organizations.find_by_slug! 'raceteam' }
    let(:sfhealth){ covered.organizations.find_by_slug! 'sfhealth' }
    let(:groups) { }

    # get /api/groups
    describe 'index' do
      context 'when given an group id' do
        context 'of an group that the current user is in' do
          it "renders all the groups of the given organization as json" do
            xhr :get, :index, format: :json, organization_id: raceteam.slug
            expect(response).to be_ok
            expect(response.body).to eq Api::GroupsSerializer.serialize(covered, raceteam.groups.all).to_json
          end
        end
        context 'of an group that the current user is not in' do
          it 'renders not found' do
            xhr :get, :index, format: :json, organization_id: sfhealth.slug
            expect(response.status).to eq 404
            expect(response.body).to be_blank
          end
        end
        context 'of an group that does not exist current user is not in' do
          it 'renders not found' do
            xhr :get, :index, format: :json, organization_id: 'foobar'
            expect(response.status).to eq 404
            expect(response.body).to be_blank
          end
        end
      end
    end

    # get /api/groups/:id
    describe 'show' do
      let(:electronics) { raceteam.groups.find_by_email_address_tag('electronics') }

      context 'when given a valid group id' do
        it "renders the current users's groups as json" do
          xhr :get, :show, format: :json, organization_id: raceteam.slug, id: electronics.email_address_tag
          expect(response).to be_ok
          expect(response.body).to eq Api::GroupsSerializer.serialize(covered, electronics).to_json
        end
      end
      context 'when given an invalid group id' do
        it "returns a 404" do
          xhr :get, :show, format: :json, organization_id: raceteam.slug, id: 'foobar'
          expect(response.status).to eq 404
          expect(response.body).to be_blank
        end
      end
    end

    # post /api/groups
    describe 'create' do
      context 'when given a unique group name' do
        it 'creates and returns the new group' do
          xhr :post, :create, format: :json, organization_id: raceteam.slug, group: { name: 'Fluffy', color: '#bebebe' }
          expect(response.status).to eq 201
          group = raceteam.groups.find_by_email_address_tag('fluffy')
          expect(group).to be
          expect(response.body).to eq Api::GroupsSerializer.serialize(covered, group).to_json
        end
      end

      context 'when given a group name that is already taken' do
        it 'returns a 422 unprocessible entity code' do
          xhr :post, :create, format: :json, organization_id: raceteam.slug, group: { name: 'Electronics', color: '#bebebe' }
          expect(response.status).to eq 409 #conflict
          expect(response.body).to be_blank
        end
      end

      context 'when given no group name' do
        it 'raises an ParameterMissing error' do
          expect {
            xhr :post, :create, format: :json, organization_id: raceteam.slug, group: { color: '#bebebe' }
          }.to raise_error(ActionController::ParameterMissing)
        end
      end

    end

    # patch /api/groups/:id
    describe 'update' do
      let(:electronics) { raceteam.groups.find_by_email_address_tag('electronics') }

      context 'when given a valid group id' do
        it "updates the group and returns the new one" do
          xhr :patch, :update, format: :json, organization_id: raceteam.slug, id: electronics.email_address_tag, group: { color: '#964bf8' }
          expect(response).to be_ok
          expect(raceteam.groups.find_by_email_address_tag('electronics').color).to eq '#964bf8'
          expect(response.body).to eq Api::GroupsSerializer.serialize(covered, electronics).to_json
        end
      end
      context 'when given an invalid group id' do
        it "returns a 404" do
          xhr :patch, :update, format: :json, organization_id: raceteam.slug, id: 'foobar', group: { color: '#964bf8' }
          expect(response.status).to eq 404
          expect(response.body).to be_blank
        end
      end

    end

    # delete /api/groups/:id
    describe 'destroy' do
      let(:electronics) { raceteam.groups.find_by_email_address_tag('electronics') }

      context 'when given a valid group id' do
        it "deletes the group" do
          xhr :delete, :destroy, format: :json, organization_id: raceteam.slug, id: electronics.email_address_tag
          expect(response.status).to eq 204
          expect(raceteam.groups.find_by_email_address_tag('electronics')).to be_nil
          expect(response.body).to be_blank
        end
      end
      context 'when given an invalid group id' do
        it "returns a 404" do
          xhr :delete, :destroy, format: :json, organization_id: raceteam.slug, id: 'foobar'
          expect(response.status).to eq 404
          expect(response.body).to be_blank
        end
      end
    end

  end


end
