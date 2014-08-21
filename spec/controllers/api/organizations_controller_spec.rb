require 'spec_helper'

describe Api::OrganizationsController, :type => :controller do

  when_not_signed_in do
    describe 'index' do
      it 'renders unauthorized' do
        xhr :get, :index, format: :json
        expect(response.status).to eq 401
      end
    end
    describe 'show' do
      it 'renders unauthorized' do
        xhr :get, :show, format: :json, id: 1
        expect(response.status).to eq 401
      end
    end
    # describe 'create' do
    #   it 'renders unauthorized' do
    #     xhr :post, :create, format: :json
    #     expect(response.status).to eq 401
    #   end
    # end
    describe 'update' do
      it 'renders unauthorized' do
        xhr :patch, :update, format: :json, id: 1
        expect(response.status).to eq 401
      end
    end
    # describe 'destroy' do
    #   it 'renders unauthorized' do
    #     xhr :delete, :destroy, format: :json, id: 1
    #     expect(response.status).to eq 401
    #   end
    # end
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
        it "should fail with not found" do
          xhr :get, :show, format: :json, id: 32843874832
          expect(response.status).to eq 404
        end
      end
    end

    # patch /api/organizations/:id
    describe 'update' do
      context 'when the user is an owner' do
        when_signed_in_as 'alice@ucsd.example.com' do
          let(:alice) { raceteam.members.find_by_email_address('alice@ucsd.example.com') }

          it 'sets the google auth user to the current user and returns the updated organization' do
            xhr :patch, :update, format: :json, id: raceteam.slug, organization: { name: 'Racy Team', description: 'foo', public_signup: false }
            expect(response.status).to eq 200
            updated_organization = threadable.organizations.find_by_slug!('raceteam')
            expect(updated_organization.description).to eq 'foo'
            expect(updated_organization.public_signup?).to be_falsey
            expect(updated_organization.name).to eq 'Racy Team'
            expect(response.body).to eq serialize(:organizations, updated_organization).to_json
          end
        end
      end

      context 'when the user does not have the correct permissions' do
        it 'fails authorization' do
          xhr :patch, :update, format: :json, id: raceteam.slug, organization: { description: 'foo', public_signup: false }
          expect(response.status).to eq 401
        end
      end
    end

    # delete /api/organizations/:id
    describe 'destroy' do

    end

    describe 'claim_google_account' do
      context 'when the user is an owner' do
        when_signed_in_as 'alice@ucsd.example.com' do
          let(:alice) { raceteam.members.find_by_email_address('alice@ucsd.example.com') }

          before do
            alice.external_authorizations.add_or_update!(
              provider: 'google_oauth2',
              token: 'foo',
              refresh_token: 'moar foo',
              name: 'Alice Neilson',
              email_address: 'alice@foo.com',
              domain: 'foo.com',
            )
          end

          it 'sets the google auth user to the current user and returns the updated organization' do
            xhr :post, :claim_google_account, format: :json, organization_id: raceteam.slug
            expect(response.status).to eq 200
            updated_organization = threadable.organizations.find_by_slug!('raceteam')
            expect(updated_organization.google_user).to eq alice
            expect(response.body).to eq serialize(:organizations, updated_organization).to_json
          end
        end
      end

      context 'when the user does not have the correct permissions' do
        it 'fails authorization' do
          xhr :post, :claim_google_account, format: :json, organization_id: raceteam.slug
          expect(response.status).to eq 401
        end
      end
    end

  end


end
