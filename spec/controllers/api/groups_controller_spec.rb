require 'spec_helper'

describe Api::GroupsController do

  when_not_signed_in do
    describe 'index' do
      it 'renders unauthorized' do
        xhr :get, :index, format: :json, organization_id: 1
        expect(response.status).to eq 401
      end
    end
    describe 'create' do
      it 'renders unauthorized' do
        xhr :post, :create, format: :json, organization_id: 1
        expect(response.status).to eq 401
      end
    end
    describe 'show' do
      it 'renders unauthorized' do
        xhr :get, :show, format: :json, organization_id: 1, group_id: 1, id: 1
        expect(response.status).to eq 401
      end
    end
    describe 'update' do
      it 'renders unauthorized' do
        xhr :patch, :update, format: :json, organization_id: 1, group_id: 1, id: 1
        expect(response.status).to eq 401
      end
    end
  end

  when_signed_in_as 'alice@ucsd.example.com' do

    let(:raceteam){ threadable.organizations.find_by_slug! 'raceteam' }
    let(:sfhealth){ threadable.organizations.find_by_slug! 'sfhealth' }
    let(:groups) { }

    # get /api/groups
    describe 'index' do
      context 'when given an group id' do
        context 'of an group that the current user is in' do
          it "renders all the groups of the given organization as json" do
            xhr :get, :index, format: :json, organization_id: raceteam.slug
            expect(response).to be_ok
            expect(response.body).to eq serialize(:groups, raceteam.groups.all).to_json
          end
        end
        context 'of an group that the current user is not in' do
          it 'renders not found' do
            xhr :get, :index, format: :json, organization_id: sfhealth.slug
            expect(response.status).to eq 404
          end
        end
        context 'of an group that does not exist current user is not in' do
          it 'renders not found' do
            xhr :get, :index, format: :json, organization_id: 'foobar'
            expect(response.status).to eq 404
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
          expect(response.body).to eq serialize(:groups, electronics).to_json
        end
      end
      context 'when given an invalid group id' do
        it "returns a 404" do
          xhr :get, :show, format: :json, organization_id: raceteam.slug, id: 'foobar'
          expect(response.status).to eq 404
        end
      end
    end

    # post /api/groups
    describe 'create' do
      context 'when given a unique group name' do
        it 'creates and returns the new group' do
          xhr :post, :create, format: :json, organization_id: raceteam.slug, group: { name: 'Fluffy', color: '#bebebe', email_address_tag: 'floofy', description: 'The Floof', subject_tag: 'FL', auto_join: false, alias_email_address: 'foo@bar.com' }
          expect(response.status).to eq 201
          group = raceteam.groups.find_by_email_address_tag('floofy')
          expect(group).to be
          expect(group.name).to eq 'Fluffy'
          expect(group.subject_tag).to eq 'FL'
          expect(group.auto_join?).to eq false
          expect(group.alias_email_address).to eq 'foo@bar.com'
          expect(group.description).to eq 'The Floof'
          expect(response.body).to eq serialize(:groups, group).to_json
        end
      end

      context 'when given a group name that is already taken' do
        it 'returns a 422 unprocessible entity code' do
          xhr :post, :create, format: :json, organization_id: raceteam.slug, group: { name: 'Electronics', color: '#bebebe' }
          expect(response.status).to eq 406
          expect(response_json).to eq({"error"=>"Name has already been taken and Email address tag has already been taken"})
        end
      end

      context 'when given no group name' do
        it 'raises an ParameterMissing error' do
          xhr :post, :create, format: :json, organization_id: raceteam.slug, group: { color: '#bebebe' }
          expect(response.status).to eq 406
          expect(response_json).to eq({"error"=>"Name can't be blank, Name is invalid, and Email address tag is invalid"})
        end
      end

    end

    # patch /api/groups/:id
    describe 'update' do
      let(:electronics) { raceteam.groups.find_by_email_address_tag('electronics') }

      context 'when given a valid group id' do
        it "updates the group and returns the new one" do
          xhr :patch, :update, format: :json, organization_id: raceteam.slug, id: electronics.email_address_tag, group: { color: '#964bf8', description: 'They are super', subject_tag: "superheroes", auto_join: false, alias_email_address: 'foo@bar.com' }
          expect(response).to be_ok
          group = raceteam.groups.find_by_email_address_tag('electronics')
          expect(group.color).to eq '#964bf8'
          expect(group.subject_tag).to eq 'superheroes'
          expect(group.auto_join?).to be_false
          expect(group.alias_email_address).to eq 'foo@bar.com'
          expect(group.description).to eq 'They are super'
          expect(response.body).to eq serialize(:groups, group).to_json
        end
      end

      context 'when given a new email address tag' do
        it "ignores the new email address tag" do
          xhr :patch, :update, format: :json, organization_id: raceteam.slug, id: electronics.email_address_tag, group: { color: '#964bf8', subject_tag: "superheroes", email_address_tag: "hey" }
          expect(response).to be_ok
          group = raceteam.groups.find_by_email_address_tag('electronics')
          expect(response.body).to eq serialize(:groups, group).to_json
        end
      end

      context 'when given an invalid group id' do
        it "returns a 404" do
          xhr :patch, :update, format: :json, organization_id: raceteam.slug, id: 'foobar', group: { color: '#964bf8', subject_tag: "superheroes" }
          expect(response.status).to eq 404
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
        end
      end
      context 'when given an invalid group id' do
        it "returns a 404" do
          xhr :delete, :destroy, format: :json, organization_id: raceteam.slug, id: 'foobar'
          expect(response.status).to eq 404
        end
      end
    end

  end


end
